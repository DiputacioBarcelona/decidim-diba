# frozen_string_literal: true

module Decidim
  module Ldap
    # A command with all the business logic when updating an ldap configuration in
    # the system.
    class UpdateLdapConfiguration < Rectify::Command

      # Public: Initializes the command.
      #
      # form - A form object with the params.
      def initialize(ldap_configuration, form)
        @ldap_configuration = ldap_configuration
        @form = form
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        update_ldap_configuration
        broadcast(:ok)
      end

      private

      attr_reader :form

      def update_ldap_configuration
        @ldap_configuration.update_attributes!(attributes)
      end

      def attributes
        {
          organization_id: form.organization,
          host: form.host,
          port: form.port,
          dn: form.dn,
          authentication_query: form.authentication_query,
          username_field: form.username_field,
          email_field: form.email_field,
          password_field: form.password_field,
          name_field: form.name_field
        }
      end

    end
  end
end
