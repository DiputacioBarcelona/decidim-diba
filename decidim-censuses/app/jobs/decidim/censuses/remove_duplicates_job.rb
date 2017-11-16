module Decidim
  module Censuses
    class RemoveDuplicatesJob < ApplicationJob

      queue_as :default

      def perform
        duplicated = Census.select(:id_document)
                           .group(:id_document)
                           .having('count(id_document)>1')
                           .map(&:id_document)

        duplicated.each do |id_doc|
          Census.where(id_document: id_doc).order(id: :desc).all[1..-1].each(&:delete)
        end
      end

    end
  end
end
