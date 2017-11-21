
module Decidim
  module Census
    # Provides information about the current status of the census data
    class Status

      # Returns the date of the last import
      def last_import_at
        @last ||= CensusDatum.order(created_at: :desc).first
        @last ? @last.created_at : nil
      end

      # Returns the number of unique census
      def count
        @count ||= CensusDatum.distinct.count(:id_document)
        @count
      end

    end
  end
end
