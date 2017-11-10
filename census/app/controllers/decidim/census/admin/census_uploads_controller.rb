module Decidim
  module Census
    module Admin
      class CensusUploadsController < Decidim::Census::ApplicationController

        def show
          render plain: 'hola'
        end

      end
    end
  end
end
