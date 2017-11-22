module Decidim
  module DibaCensusApi
    module Admin
      class ApiConfigsController < Decidim::Admin::ApplicationController

        before_action :show_instructions, unless: :module_active?

        def show
          authorize! :show, Decidim::Organization
          @organization = current_organization
        end

        def edit
          authorize! :edit, Decidim::Organization
          @organization = current_organization
        end

        def update
          authorize! :update, Decidim::Organization
          @organization = current_organization
          @organization.update!(organization_params)
          redirect_to api_config_path
        end

        private

        def organization_params
          params.require(:organization).permit(:diba_census_api_ine,
                                               :diba_census_api_username,
                                               :diba_census_api_password)
        end

        def show_instructions
          render :instructions
        end

        def module_active?
          current_organization.available_authorizations.include? 'DibaCensusApiAuthorizationHandler'
        end

      end
    end
  end
end
