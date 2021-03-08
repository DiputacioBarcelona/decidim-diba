# frozen_string_literal: true

module Decidim
  module Ldap
    module Extensions
      module ControllerWithLdapPermissions
        def permission_class_chain
          super + [Decidim::Ldap::Permissions::ExtraAccountPermissions]
        end
      end
    end
  end
end
