# frozen_string_literal: true

module Decidim
  module Admin
    module NewslettersControllerOverrides
      extend ActiveSupport::Concern

      included do
        private

        def newsletter_params
          params.fetch(:newsletter, {}).permit(
            :send_to_all_users,
            :send_to_verified_users,
            :send_to_followers,
            :send_to_participants,
            :send_to_private_members,
            :send_to_selected_users,
            :copy_newsletter_selected_users_ids,
            selected_users_ids: [],
            verification_types: [],
            participatory_space_types: {
              assemblies: [:manifest_name, { ids: [] }],
              conferences: [:manifest_name, { ids: [] }],
              initiatives: [:manifest_name, { ids: [] }],
              participatory_processes: [:manifest_name, { ids: [] }]
            }
          )
        end
      end
    end
  end
end
