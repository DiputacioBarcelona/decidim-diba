# frozen_string_literal: true

module Decidim
  module Ldap
    # Controller to manage Organizations LDAP config
    #
    class LdapConfigurationsController < Decidim::System::ApplicationController

      def index
        @ldap_configurations = LdapConfiguration.all
      end

      def new
        @organizations = Organization.all
        @form = form(LdapConfigurationForm).instance
      end

      def show
        @ldap_configuration = LdapConfiguration.find(params[:id])
      end

      def edit
        @organizations = Organization.all
        @ldap_configuration = LdapConfiguration.find(params[:id])
        @form = form(LdapConfigurationForm).from_model(@ldap_configuration)
      end

      def create
        @organizations = Organization.all
        @form = form(LdapConfigurationForm).from_params(params)

        call_create_form
      end

      def update
        @organizations = Organization.all
        @ldap_configuration = LdapConfiguration.find(params[:id])
        @form = form(LdapConfigurationForm).from_params(params)

        call_update_form
      end

      def destroy
        @ldap_configuration = LdapConfiguration.find(params[:id]).destroy!
        flash[:notice] = I18n.t('ldap_configurations.destroy.success',
                                scope: 'decidim.ldap')

        redirect_to ldap_configurations_path
      end

      private

      def call_create_form
        CreateLdapConfiguration.call(@form) do
          on(:ok) do
            flash[:notice] = I18n.t('ldap_configurations.create.success',
                                    scope: 'decidim.ldap')
            redirect_to ldap_configurations_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t('ldap_configurations.create.error',
                                       scope: 'decidim.ldap')
            render :new
          end
        end
      end

      def call_update_form
        UpdateLdapConfiguration.call(@ldap_configuration, @form) do
          on(:ok) do
            flash[:notice] = I18n.t('ldap_configurations.update.success',
                                    scope: 'decidim.ldap')
            redirect_to ldap_configurations_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t('ldap_configurations.update.error',
                                       scope: 'decidim.ldap')
            render :edit
          end
        end
      end

      def root_path
        decidim_system.root_path
      end
      helper_method :root_path

      def destroy_admin_session_path
        decidim_system.destroy_admin_session_path
      end
      helper_method :destroy_admin_session_path

    end
  end
end
