# frozen_string_literal: true

require "decidim/components/namer"
require "decidim/core/test/factories"
require "decidim/participatory_processes/test/factories"

FactoryBot.define do
  factory :process_settings_component, parent: :component do
    name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :process_settings).i18n_name }
    manifest_name { :process_settings }
    participatory_space { create(:participatory_process) }

    trait :with_automatic_step_change do
      settings { { automatic_step_change: true } }
    end
  end
end
