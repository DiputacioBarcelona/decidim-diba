module Decidim
  module Censuses
    module Admin
      class CensusUploadsController < Decidim::Censuses::Admin::ApplicationController

        def show
          authorize! :show, Census
          @censuses = OpenStruct.new(
            count: Census.count, last_import_at: Census.last_import_at
          )
        end

        def create
          authorize! :create, Census
          if params[:file]
            result = Census.load_csv(params[:file].path)
            flash[:notice] = t('.success', count: Census.count, errors: result[:errors])
          end
          redirect_to census_uploads_path
        end

      end
    end
  end
end
