require 'csv'
require 'activerecord-import/base'
ActiveRecord::Import.require_adapter('postgres')

module Decidim
  module Censuses
    class Census < ApplicationRecord

      def self.last_import_at
        last = Census.order(created_at: :desc).first
        last ? last.created_at : nil
      end

      def self.load_csv(file)
        Census.delete_all

        errors = 0
        columns = %i(id_document birthdate)
        values = []
        CSV.foreach(file, headers: true, col_sep: ';') do |row|
          begin
            values << [
              (row[0] || '').strip,
              Date.strptime((row[1] || '').strip, '%d/%m/%Y')
            ]
          rescue StandardError
            errors += 1
          end
        end

        Rails.logger.silence do
          Census.import columns, values, validate: false
        end

        { errors: errors }
      end
    end
  end
end
