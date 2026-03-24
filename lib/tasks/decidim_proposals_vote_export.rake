# frozen_string_literal: true

require "csv"
require "set"

namespace :decidim_proposals do
  desc "Export per-user proposal vote statistics for a proposals component to CSV."
  task :export_component_vote_stats, [:component_id, :output_path] => :environment do |_t, args|
    component_id = args[:component_id].presence || ENV["COMPONENT_ID"]
    component = Decidim::Component.find_by(id: component_id)
    output_path = args[:output_path].presence || ENV["OUTPUT_PATH"].presence || Rails.root.join("tmp", "proposal_votes_component_#{component.id}_#{Time.zone.now.strftime('%Y%m%d%H%M%S')}.csv").to_s
    unless component_id.present?
      abort "Missing component id. Example: bin/rails decidim_proposals:export_component_vote_stats[123]"
    end

    abort "Component #{component_id} not found." unless component
    abort "Component #{component_id} is not a proposals component (manifest: #{component.manifest_name})." unless component.manifest_name == "proposals"

    votes_scope = Decidim::Proposals::ProposalVote
      .joins(:proposal)
      .where(decidim_proposals_proposals: { decidim_component_id: component.id })

    vote_table = Decidim::Proposals::ProposalVote.arel_table

    rows = votes_scope
      .group(vote_table[:decidim_author_id])
      .order(vote_table[:decidim_author_id])
      .pluck(
        vote_table[:decidim_author_id],
        Arel.sql("COUNT(*)"),
        Arel.sql("COALESCE(SUM(CASE WHEN #{vote_table.name}.temporary THEN 1 ELSE 0 END), 0)"),
        Arel.sql("COALESCE(SUM(CASE WHEN #{vote_table.name}.temporary THEN 0 ELSE 1 END), 0)"),
        Arel.sql("MIN(CASE WHEN #{vote_table.name}.temporary = FALSE THEN #{vote_table.name}.created_at END)"),
        Arel.sql("MAX(CASE WHEN #{vote_table.name}.temporary = FALSE THEN #{vote_table.name}.created_at END)"),
        Arel.sql("MAX(CASE WHEN #{vote_table.name}.temporary = TRUE THEN #{vote_table.name}.created_at END)")
      )

    author_ids_with_duplicate_votes_on_same_proposal =
      votes_scope
        .group(vote_table[:decidim_author_id], vote_table[:decidim_proposal_id])
        .having(Arel.sql("COUNT(*) > 1"))
        .pluck(vote_table[:decidim_author_id])
        .uniq
        .to_set

    author_ids = rows.map(&:first)
    nicknames_by_id = Decidim::User.where(id: author_ids).pluck(:id, :nickname).to_h

    FileUtils.mkdir_p(File.dirname(output_path))

    byebug
    CSV.open(output_path, "wb", write_headers: true, headers: [
      "author_id",
      "author_nickname",
      "votes_count",
      "temporary_votes_count",
      "final_votes_count",
      "first_final_vote_at",
      "last_final_vote_at",
      "last_temporary_vote_at",
      "multiple_votes_on_same_proposal"
    ]) do |csv|
      rows.each do |author_id, total, temporary_count, final_count, first_final_at, last_final_at, last_temporary_at|
        csv << [
          author_id,
          nicknames_by_id[author_id].to_s,
          total,
          temporary_count,
          final_count,
          first_final_at&.iso8601,
          last_final_at&.iso8601,
          last_temporary_at&.iso8601,
          author_ids_with_duplicate_votes_on_same_proposal.include?(author_id)
        ]
      end
    end

    puts "Wrote #{rows.size} rows to #{output_path}"
  end
end
