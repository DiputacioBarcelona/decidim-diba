# frozen_string_literal: true

module Decidim
  module Ldap
    # A form object used to create ldap configurations from the system dashboard.
    #
    class LdapConfigurationForm < Form

      mimic :ldap_configuration

      attribute :organization, Integer
      attribute :host, String
      attribute :port, String
      attribute :dn, String
      attribute :authentication_query, String
      attribute :username_field, String
      attribute :email_field, String
      attribute :password_field, String
      attribute :name_field, String

      validates :organization, :host, :port, :dn, :authentication_query, :username_field,
                :email_field, :password_field, :name_field, presence: true

      def map_model(model)
        self.organization = model.organization_id
      end

    end
  end
end
