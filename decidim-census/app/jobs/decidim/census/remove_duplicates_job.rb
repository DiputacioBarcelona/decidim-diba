module Decidim
  module Census
    class RemoveDuplicatesJob < ApplicationJob

      queue_as :default

      def perform
        duplicated_census.pluck(:id_document).each do |id_document|
          CensusDatum.where(id_document: id_document).order(id: :desc).all[1..-1].each(&:delete)
        end
      end

      private

      def duplicated_census
        CensusDatum.select(:id_document).group(:id_document).having('count(id_document)>1')
      end

    end
  end
end
