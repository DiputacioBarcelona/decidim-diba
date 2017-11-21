require 'csv'
require 'pry'

module Decidim
  module Censuses
    class Census < ApplicationRecord

      def self.for_document(string)
        id_doc = to_id_document(string)
        Census.where(id_document: id_doc).order(created_at: :desc, id: :desc).first
      end

      def self.to_id_document(string)
        return '' unless string
        string.gsub(/[^A-z0-9]/, '').upcase
      end

      def self.to_birthdate(string)
        Date.strptime((string || '').strip, '%d/%m/%Y')
      rescue StandardError
        nil
      end

      def self.insert_all(values)
        table_name = Census.table_name
        columns = %w[id_document birthdate created_at].join(',')
        now = Time.current
        values = values.map { |row| "('#{row[0]}', '#{row[1]}', '#{now}')" }.join(',')
        sql = "INSERT INTO #{table_name} (#{columns}) VALUES #{values}"
        ActiveRecord::Base.connection.execute(sql)
      end

    end
  end
end
