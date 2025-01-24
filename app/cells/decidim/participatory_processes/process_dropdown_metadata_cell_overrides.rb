# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module ProcessDropdownMetadataCellOverrides
      extend ActiveSupport::Concern

      included do
        include ::ApplicationHelper

        private

        def cache_hash
          hash = []
          hash << "decidim/process_dropdown_metadata"
          hash << id
          hash << process.cache_key_with_version
          hash << process.active_step&.cache_key_with_version.to_s
          hash << current_user.try(:id).to_s
          hash << components_collection.cache_key_with_version
          hash << I18n.locale.to_s

          hash.join(Decidim.cache_key_separator)
        end

        def components_collection
          process.components.published.or(Decidim::Component.where(id: try(:current_component)))
        end
      end
    end
  end
end
