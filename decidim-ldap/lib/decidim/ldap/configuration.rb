module Decidim
  module Ldap
    class Configuration

      attr_writer :ldap_username, :ldap_password

      def ldap_username
        @ldap_username or fail 'You need to provide a ldap_username. See the app README.'
      end

      def ldap_password
        @ldap_password or fail 'You need to provide a ldap_password. See the app README.'
      end

    end
  end
end
