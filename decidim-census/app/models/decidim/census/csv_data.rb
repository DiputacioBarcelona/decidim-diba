require 'csv'

module Decidim
  module Census
    class CsvData

      attr_reader :errors, :values

      def initialize(file)
        @file = file
        @errors = []
        @values = []

        CSV.foreach(@file, headers: true, col_sep: ';') do |row|
          process_row(row)
        end
      end

      private

      def process_row(row)
        id_document = Decidim::Census::CensusDatum.normalize_id_document(row[0])
        date = Decidim::Census::CensusDatum.parse_date(row[1])
        if id_document.present? && !date.nil?
          values << [id_document, date]
        else
          errors << row
        end
      end

    end
  end
end