# frozen_string_literal: true

module Decidim
  module Census
    class ImportSubcensusDocuments < Decidim::Command
      def initialize(subcensus, documents_file, organization)
        @subcensus = subcensus
        @documents_file = documents_file
        @organization = organization
      end

      def call
        return if @documents_file.blank?

        data = SubcensusCsvData.new(@documents_file, @organization)
        @subcensus.documents.destroy_all
        SubcensusDocument.insert_documents(@subcensus, data.values)
        broadcast(:ok, data)
      end
    end
  end
end
