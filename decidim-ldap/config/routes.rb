# frozen_string_literal: true

Decidim::Ldap::Engine.routes.draw do
  authenticate(:admin) do
    resources :ldap_configurations
  end
end
