# frozen_string_literal: true

unless ActiveModel::Type::Boolean.new.cast(ENV['DOCKER'])
  Deface::Override.new(virtual_path: 'layouts/decidim/_wrapper',
                     name: 'remove_signup_link_in_wrapper',
                     replace: "erb[loud]:contains('if current_organization.sign_up_enabled?')",
                     text: '<% if current_organization.sign_up_enabled? || current_organization.ldap? %>')
end
