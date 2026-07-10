# frozen_string_literal: true

module Decidim
  module Exporters
    # Overrides Decidim::Exporters::CSV#export to prepend the UTF-8 byte order
    # mark to the generated CSV, so spreadsheet software (notably Microsoft
    # Excel) detects the encoding and renders non-ASCII characters correctly.
    #
    # Upstream Decidim does not include the BOM and the maintainers won't accept
    # this change, so it is applied locally as an override instead of forking.
    module CsvOverrides
      # UTF-8 byte order mark.
      BOM = "﻿"

      # Public: Exports a CSV serialized version of the collection, prepending
      # the UTF-8 BOM to the output.
      #
      # Returns an ExportData instance.
      def export(col_sep = Decidim.default_csv_col_sep)
        data = ::CSV.generate(BOM.dup, headers:, write_headers: true, col_sep:) do |csv|
          processed_collection.each do |resource|
            csv << headers.map { |header| custom_sanitize(resource[header]) }
          end
        end
        ExportData.new(data, "csv")
      end
    end
  end
end
