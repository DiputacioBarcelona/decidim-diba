# frozen_string_literal: true

module Decidim
  module Census
    module Admin
      class CensusesController < Decidim::Census::Admin::ApplicationController
        CENSUS_AUTHORIZATIONS = %w(diba_authorization_handler
                                   census_authorization_handler).freeze

        before_action :show_instructions,
                      unless: :census_authorization_active_in_organization?
        before_action :set_status, on: [:show, :create]

        def show
          enforce_permission_to :create, :census
        end

        def create
          enforce_permission_to :create, :census

          if params[:file]
            data = CsvData.new(params[:file].path)
            CensusDatum.insert_all(current_organization, data.values)
            RemoveDuplicatesJob.perform_later(current_organization)
            @invalid_rows = data.errors
            flash[:notice] = t(".success", count: data.values.count,
                                           errors: data.errors.count)
          end
          render :show
        end

        def destroy
          enforce_permission_to :destroy, :census

          CensusDatum.clear(current_organization)
          redirect_to censuses_path, notice: t(".success")
        end

        private

        def show_instructions
          render :instructions
        end

        def set_status
          @status = Status.new(current_organization)
        end

        def census_authorization_active_in_organization?
          (current_organization.available_authorizations & CENSUS_AUTHORIZATIONS).any?
        end
      end
    end
  end
end
