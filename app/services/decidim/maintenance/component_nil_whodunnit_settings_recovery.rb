# frozen_string_literal: true

module Decidim
  module Maintenance
    # Reconstructs Decidim::Component `settings` after PaperTrail versions with a blank
    # `whodunnit` (e.g. taxonomy import)
    #
    # Does not fix rows mutated via `update_columns` on `settings` (no PaperTrail version).
    class ComponentNilWhodunnitSettingsRecovery
      Result = Struct.new(
        :item_id,
        :status,
        :case_type,
        :applied,
        :message,
        :recovered_settings,
        keyword_init: true
      )

      # @param since [Time, Date, String] only components with at least one nil-whodunnit version on or after this time are processed
      # @param dry_run [Boolean] when true (default), do not persist; only compute and report
      # @param whodunnit_user_id [Integer, nil] required for apply (when dry_run is false)
      # @skip_types [Array] array of types to be skipped (:B, :C, :D) blank by default
      # @reprocess_whodunnit [Boolean] when false the componets which last version is of whodunnit_user will be skipped. true by default
      # @param limit [Integer, nil] when set, process at most this many component ids (stable order by item_id)
      # @param offset [Integer] skip this many component ids before applying limit (default 0)
      # @return_recovered [Boolean] when true (default) the output includes the recovered_settings. Set this argument to false if there
      #                   are capacity issues on the machine where it is called
      #
      def initialize(since:, dry_run: true, whodunnit_user_id: nil, skip_types: [], reprocess_whodunnit: true, limit: nil, offset: 0, return_recovered: true)
        @since = coerce_since(since)
        @dry_run = dry_run
        @whodunnit_user_id = whodunnit_user_id
        @whodunnit_gid = whodunnit_user_id.presence && Decidim::User.find_by(id: whodunnit_user_id)&.to_gid&.to_s
        @skip_types = skip_types.map(&:to_sym).intersection([:B, :C, :D])
        @reprocess_whodunnit = reprocess_whodunnit
        @limit = coerce_limit(limit)
        @offset = coerce_offset(offset)
        @return_recovered = return_recovered
      end

      # @return [Array<Result>]
      def call
        gated_item_ids.map { |item_id| process_component(item_id) }
      end

      private

      attr_reader :since, :dry_run, :whodunnit_user_id, :whodunnit_gid, :skip_types, :reprocess_whodunnit, :limit,
                  :offset, :return_recovered

      def coerce_since(value)
        time = value.is_a?(Time) ? value : Time.zone.parse(value.to_s)
        raise ArgumentError, "Invalid date/time: #{value.inspect}" if time.nil?

        time
      end

      def coerce_limit(value)
        return nil if value.nil?

        n = Integer(value)
        raise ArgumentError, "limit must be a positive integer, got #{value.inspect}" unless n.positive?

        n
      end

      def coerce_offset(value)
        n = Integer(value)
        raise ArgumentError, "offset must be non-negative, got #{value.inspect}" if n.negative?

        n
      end

      def gated_item_ids
        scope = PaperTrail::Version
                .where(item_type: "Decidim::Component")
                .where(created_at: since..)
                .where("whodunnit IS NULL OR whodunnit = ?", "")
                .distinct
                .order(:item_id)
        scope = scope.limit(limit) if limit
        scope = scope.offset(offset) if offset.positive?

        scope.pluck(:item_id)
      end

      def process_component(item_id)
        component = find_component(item_id)
        return component if component.is_a?(Result)

        versions_data = extract_versions_data(item_id)
        return versions_data if versions_data.is_a?(Result)

        baseline = baseline_settings_hash(versions_data[:first_nil])
        case_type = classify_case(versions_data)

        recovered = deep_dup_settings(baseline)
        recovered["taxonomy_filters"] = taxonomy_filters_from_version_new_state(versions_data)

        # After merge, snapshot for case D replay: unchanged paths in attributed versions
        # use this reference (baseline + merged taxonomy) so replay does not strip taxonomy_filters.
        replay_reference = deep_dup_settings(recovered)

        if case_type == :D
          idx = versions_data[:all_versions].index(versions_data[:first_nil])
          versions_data[:all_versions][(idx + 1)..]&.each do |v|
            next if whodunnit_blank?(v)

            apply_attributed_version!(recovered, replay_reference, v)
          end
        end

        current = deep_dup_settings(component.settings.to_h)
        changed = !settings_equal?(current, recovered)

        recovered_output = return_recovered ? recovered : nil

        if dry_run
          return Result.new(item_id:, status: :ok, case_type:, applied: false,
                            message: changed ? "Would update settings" : "No change needed",
                            recovered_settings: recovered_output)
        end

        unless changed
          return Result.new(item_id:, status: :ok, case_type:, applied: false,
                            message: "Already matches recovered settings",
                            recovered_settings: recovered_output)
        end

        gid = whodunnit_gid
        unless gid
          return Result.new(item_id:, status: :error, case_type:, applied: false,
                            message: "WHODUNNIT_USER_ID is required when DRY_RUN=false",
                            recovered_settings: recovered_output)
        end

        if skip_types.present? && skip_types.include?(case_type)
          Result.new(item_id:, status: :ok, case_type:, applied: false,
                     message: "Update skipped because type is #{case_type}", recovered_settings: recovered_output)
        else
          PaperTrail.request(whodunnit: gid) do
            persist_recovered!(component, recovered)
          end

          Result.new(item_id:, status: :ok, case_type:, applied: true,
                     message: "Settings updated", recovered_settings: recovered_output)
        end
      rescue StandardError => e
        Result.new(item_id:, status: :error, case_type: nil, applied: false,
                   message: e.message, recovered_settings: nil)
      end

      def find_component(id)
        component = Decidim::Component.unscoped.find_by(id:)
        unless component
          return Result.new(item_id: id, status: :skipped, case_type: nil, applied: false,
                            message: "Component not found", recovered_settings: nil)
        end

        if component.deleted_at.present?
          return Result.new(item_id: id, status: :skipped, case_type: nil, applied: false,
                            message: "Component is soft-deleted", recovered_settings: nil)
        end

        if !reprocess_whodunnit && whodunnit_gid.present? && component.versions.last.whodunnit == whodunnit_gid
          return Result.new(item_id: id, status: :skipped, case_type: nil, applied: false,
                            message: "Component has been already processed by #{whodunnit_gid}",
                            recovered_settings: nil)
        end

        component
      end

      def extract_versions_data(id)
        all_versions_scope = PaperTrail::Version
                             .where(item_type: "Decidim::Component", item_id: id)
                             .order(:created_at, :id)

        nils = all_versions_scope.where(whodunnit: nil, created_at: since..)

        if nils.none?
          return Result.new(item_id:, status: :skipped, case_type: nil, applied: false,
                            message: "No nil-whodunnit versions on or after cutoff", recovered_settings: nil)
        end

        first_nil = nils.first
        last_nil = nils.last

        if first_nil.event != "update"
          return Result.new(item_id:, status: :skipped, case_type: nil, applied: false,
                            message: "First problem version is not an update (cannot recover baseline)", recovered_settings: nil)
        end

        {
          first_nil:,
          last_nil:,
          all_nils: nils.to_a,
          all_versions: all_versions_scope.to_a
        }
      end

      def whodunnit_blank?(version)
        version.whodunnit.blank?
      end

      def classify_case(versions_data)
        return :B if versions_data[:all_nils].size == 1 && versions_data[:all_nils].first.id == versions_data[:all_versions].last.id

        first_global_nil_idx = versions_data[:all_versions].index { |v| whodunnit_blank?(v) }
        nil_tail = first_global_nil_idx && versions_data[:all_versions][first_global_nil_idx..].all? { |v| whodunnit_blank?(v) }

        return :C if versions_data[:all_nils].size > 1 && nil_tail

        :D
      end

      # Prefer PaperTrail reify (state before this version); fallback to changeset old settings.
      def baseline_settings_hash(version)
        reified = version.reify
        if reified
          deep_dup_settings(reified.settings.to_h || {})
        else
          pair = settings_change_pair(version)
          pair ? (deep_dup_settings(pair[0])&.dig("global") || {}) : {}
        end
      end

      def taxonomy_filters_from_version_new_state(versions_data)
        pair = settings_change_pair(versions_data[:last_nil])
        return [] unless pair

        _, new_s = pair
        extract_taxonomy_filters(new_s)
      end

      def extract_taxonomy_filters(settings_hash)
        return [] if settings_hash.blank?

        h = settings_hash.with_indifferent_access
        Array(h[:taxonomy_filters]).map(&:to_s)
      end

      def apply_attributed_version!(recovered, baseline, version)
        pair = settings_change_pair(version)
        return if pair.blank?

        old_s, new_s = pair
        apply_settings_diff_from_changeset!(recovered, baseline, old_s, new_s)
      end

      # For each path: if old == new in the changeset, keep baseline value; else take new value.
      # Recurses into nested hashes.
      def apply_settings_diff_from_changeset!(recovered, baseline, old_s, new_s)
        old_s = normalize_settings_node(old_s)
        new_s = normalize_settings_node(new_s)
        keys = (old_s.keys + new_s.keys).uniq
        keys.each do |key|
          ov = old_s[key]
          nv = new_s[key]
          b = baseline.is_a?(Hash) ? baseline[key] : nil
          if ov.is_a?(Hash) && nv.is_a?(Hash)
            recovered[key] = {} unless recovered[key].is_a?(Hash)
            b_hash = b.is_a?(Hash) ? b : {}
            apply_settings_diff_from_changeset!(recovered[key], b_hash, ov, nv)
          elsif ov == nv
            recovered[key] = deep_dup_settings(b) if baseline.is_a?(Hash) && baseline.has_key?(key)
          else
            recovered[key] = deep_dup_settings(nv)
          end
        end
      end

      def normalize_settings_node(value)
        return {} if value.nil?

        value.with_indifferent_access
      end

      def settings_change_pair(version)
        ch = changeset_for(version).with_indifferent_access
        s = ch["settings"]
        return nil unless s.is_a?(Array) && s.size == 2

        [deep_dup_settings(s[0]&.dig("global")), deep_dup_settings(s[1]&.dig("global"))]
      end

      def changeset_for(version)
        if version.object_changes.present?
          version.changeset
        else
          {}
        end
      end

      def deep_dup_settings(value, default_for_nil: nil)
        case value
        when nil
          default_for_nil
        when Hash
          value.each_with_object({}.with_indifferent_access) do |(k, v), acc|
            acc[k.to_s] = deep_dup_settings(v)
          end
        when Array
          value.map { |e| deep_dup_settings(e) }
        else
          value.respond_to?(:deep_dup) ? value.deep_dup : value
        end
      end

      def settings_equal?(settings_a, settings_b)
        deep_dup_settings(settings_a, default_for_nil: {}) == deep_dup_settings(settings_b, default_for_nil: {})
      end

      def persist_recovered!(component, recovered)
        recovered = {} unless recovered.is_a?(Hash)

        component.update!(settings: recovered)
      end
    end
  end
end
