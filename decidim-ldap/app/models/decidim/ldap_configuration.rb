module Decidim
  class LdapConfiguration < ApplicationRecord

    belongs_to :organization

    validates :organization, :host, :port, :dn, :authentication_query, :username_field,
              :email_field, :password_field, :name_field, presence: true

    def authentication_query_for_username(username)
      authentication_query.gsub('@screen_name@', username)
    end

  end
end
