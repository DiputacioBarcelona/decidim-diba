# frozen_string_literal: true

module Decidim
  module Ldap
    # A command with all the business logic when creating a new ldap configuration in
    # the system.
    class CreateLdapConfiguration < Rectify::Command

      # Public: Initializes the command.
      #
      # form - A form object with the params.
      def initialize(form)
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

        create_ldap_configuration
        broadcast(:ok)
      end

      private

      attr_reader :form

      def create_ldap_configuration
        LdapConfiguration.create!(
          organization_id: form.organization,
          host: form.host,
          port: form.port,
          dn: form.dn,
          authentication_query: form.authentication_query,
          username_field: form.username_field,
          email_field: form.email_field,
          password_field: form.password_field,
          name_field: form.name_field
        )
      end

    end
  end
end
