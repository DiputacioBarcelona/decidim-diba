module Decidim
  module Ldap
    module Extensions
      module OrganizationWithLdap
        extend ActiveSupport::Concern

        included do
          has_one :ldap_configuration
        end

        def ldap?
          ldap_configuration.present?
        end
      end
    end
  end
end
