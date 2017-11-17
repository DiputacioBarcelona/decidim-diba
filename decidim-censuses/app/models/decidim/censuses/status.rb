
module Decidim
  module Censuses
    # Provides information about the current status of the censuses data
    class Status

      # Returns the date of the last import
      def last_import_at
        @last ||= Census.order(created_at: :desc).first
        @last ? @last.created_at : nil
      end

      # Returns the number of unique census
      def count
        @count ||= Census.distinct.count(:id_document)
        @count
      end

    end
  end
end
