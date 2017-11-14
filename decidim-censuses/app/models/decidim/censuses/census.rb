require 'csv'

module Decidim
  module Censuses
    class Census < ApplicationRecord

      def self.last_import_at
        last = Census.order(created_at: :desc).first
        last ? last.created_at : nil
      end

      def self.insert_all(values)
        table_name = Census.table_name
        columns = %w[id_document birthdate created_at].join(',')
        now = Time.current
        values = values.map { |row| "('#{row[0]}', '#{row[1]}', '#{now}')" }.join(',')
        sql = "INSERT INTO #{table_name} (#{columns}) VALUES #{values}"
        Census.delete_all
        ActiveRecord::Base.connection.execute(sql)
      end

      def self.load_csv(file)
        errors = 0
        values = []
        CSV.foreach(file, headers: true, col_sep: ';') do |row|
          begin
            id_document = (row[0] || '').strip
            birthdate = Date.strptime((row[1] || '').strip, '%d/%m/%Y')
            values << [id_document, birthdate.strftime('%Y/%m/%d')]
          rescue StandardError
            errors += 1
          end
        end

        Census.insert_all(values)
        { errors: errors }
      end

    end
  end
end
