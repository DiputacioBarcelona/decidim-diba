module Decidim
  module Censuses
    class RemoveDuplicatesJob < ApplicationJob

      queue_as :default

      def perform
        duplicated_census.pluck(:id_document).each do |id_document|
          Census.where(id_document: id_document).order(id: :desc).all[1..-1].each(&:delete)
        end
      end

      private

      def duplicated_census
        Census.select(:id_document).group(:id, :id_document).having('count(id_document)>1')
      end

    end
  end
end
