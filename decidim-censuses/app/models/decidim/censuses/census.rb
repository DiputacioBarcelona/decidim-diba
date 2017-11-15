require 'csv'
require 'pry'

module Decidim
  module Censuses
    class Census < ApplicationRecord

      def self.last_import_at
        last = Census.order(created_at: :desc).first
        last ? last.created_at : nil
      end

      def self.merge_all(values)
        insert_all(values)
        remove_duplicates
      end

      private_class_method

      def self.insert_all(values)
        table_name = Census.table_name
        columns = %w[id_document birthdate created_at].join(',')
        now = Time.current
        values = values.map { |row| "('#{row[0]}', '#{row[1]}', '#{now}')" }.join(',')
        sql = "INSERT INTO #{table_name} (#{columns}) VALUES #{values}"
        ActiveRecord::Base.connection.execute(sql)
      end

      def self.remove_duplicates
        duplicated_id_documents = Census.select(:id_document)
                                        .group(:id_document)
                                        .having('count(id_document)>1')
                                        .map(&:id_document)

        duplicated_id_documents.each do |id_doc|
          Census.where(id_document: id_doc).order(id: :desc).all[1..-1].each(&:destroy)
        end
      end

    end
  end
end
