# frozen_string_literal: true

require "csv"

module Decidim
  module Census
    class SubcensusCsvData
      attr_reader :errors, :values

      def initialize(file)
        @file = file
        @errors = []
        @values = []

        @file.open do |content|
          CSV.foreach(content, headers: true, col_sep: ";") do |row|
            process_row(row)
          end
        end
      end

      private

      def process_row(row)
        id_document = CensusDatum.normalize_and_encode_id_document(row[0])
        if id_document.present?
          values << [id_document]
        else
          errors << { line: $INPUT_LINE_NUMBER, data: row }
        end
      end
    end
  end
end
