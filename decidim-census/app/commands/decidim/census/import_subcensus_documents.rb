# frozen_string_literal: true

module Decidim
  module Census
    class ImportSubcensusDocuments < Decidim::Command
      def initialize(subcensus, documents_file)
        @subcensus = subcensus
        @documents_file = documents_file
      end

      def call
        return if @documents_file.blank?

        data = SubcensusCsvData.new(@documents_file)
        @subcensus.documents.destroy_all
        SubcensusDocument.insert_documents(@subcensus, data.values)
        broadcast(:ok, data)
      end
    end
  end
end
