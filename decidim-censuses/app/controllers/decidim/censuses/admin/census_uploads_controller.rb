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
            result = CensusCsvService.load(params[:file].path)
            Census.merge_all result[:values]
            flash[:notice] = t('.success', count: Census.count, errors: result[:error_count])
          end
          redirect_to census_uploads_path
        end

      end
    end
  end
end
