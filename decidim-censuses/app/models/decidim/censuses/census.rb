require 'csv'

module Decidim
  module Censuses
    class Census < ApplicationRecord

      def self.last_import_at
        last = Census.order(created_at: :desc).first
        last ? last.created_at : nil
      end

      def self.import(file)
        Census.delete_all

        errored = []
        CSV.foreach(file, headers: true, col_sep: ';') do |row|
          begin
            dni = (row[0] || '').strip
            date = Date.strptime((row[1] || '').strip, '%d/%m/%Y')
            Census.create!(id_document: dni, birthdate: date)
          rescue StandardError
            errored << row.to_s
          end
        end

        { errored: errored }
      end

    end
  end
end
