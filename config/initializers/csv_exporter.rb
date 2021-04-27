# frozen_string_literal: true

# Customize Decidim::Exporters::CSV
# Decidim uses the attributes of the first exported item to decide which are the attributes to export.
# In Proposals, each Proposal can have the title and body in a different locale. So title and body are
# exported only in the locale of the first proposal.

# override the headers private method
module DibaHeadersFromAllProposals
  private

  def headers
    return [] if processed_collection.empty?

    processed_collection.inject([]) { |keys, resource| keys | resource.keys }
  end
end

Decidim::Exporters::CSV.prepend(DibaHeadersFromAllProposals)
