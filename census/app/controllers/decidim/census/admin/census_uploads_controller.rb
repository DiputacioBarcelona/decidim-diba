module Decidim
  module Census
    module Admin
      class CensusUploadsController < Decidim::Census::Admin::ApplicationController

        def show
          @censuses = OpenStruct.new(count: 0, last_import_at: nil)
        end

      end
    end
  end
end
