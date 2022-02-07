# frozen_string_literal: true

module Decidim
  module Ldap
    module Extensions
      module OrganizationWithLdap
        extend ActiveSupport::Concern

        included do
          has_many :ldap_configurations
        end

        def ldap?
          ldap_configurations.any?
        end
      end
    end
  end
end
