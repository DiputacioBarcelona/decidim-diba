module Decidim
  module Censuses
    module Admin
      class CensusUploadsController < Decidim::Admin::ApplicationController
        before_action :show_setup_instructions_if_needed

        def show
          authorize! :show, Census
          @censuses = OpenStruct.new(
            count: Census.count_unique, last_import_at: Census.last_import_at
          )
        end

        def create
          authorize! :create, Census
          if params[:file]
            data = CsvData.new(params[:file].path)
            Census.insert_all data.values
            RemoveDuplicatesJob.perform_later
            flash[:notice] = t('.success', count: data.values.count,
                                           errors: data.errors.count)
          end
          redirect_to census_uploads_path
        end

        def delete_all
          authorize! :destroy, Census
          Census.delete_all
          flash[:notice] = t('.success')
          redirect_to census_uploads_path
        end

        private

        def show_setup_instructions_if_needed
          render :instructions unless current_organization.available_authorizations.include? 'CensusAuthorizationHandler'
        end
      end
    end
  end
end
