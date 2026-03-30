# frozen_string_literal: true

module Decidim::Admin::SelectiveNewsletterFormDecorator
  def self.decorate
    Decidim::Admin::SelectiveNewsletterForm.class_eval do
      include Decidim::TranslatableAttributes

      attribute :selected_users_ids, Array
      attribute :send_to_selected_users, ::Decidim::AttributeObject::Form::Boolean
      validates :send_to_selected_users, presence: true, if: :only_selected_users_selected?

      def newsletters_with_selected_recipients_options
        Decidim::Newsletter
          .where(organization: current_organization)
          .where.not(sent_at: nil)
          .where("extended_data @> ?", Arel.sql({ send_to_selected_users: true }.to_json))
          .filter_map do |newsletter|
            [translated_attribute(newsletter.subject), newsletter.id] if newsletter.extended_data["selected_users_ids"]&.compact_blank.present?
          end
      end

      private

      def at_least_one_participatory_space_selected
        return if (send_to_all_users || send_to_verified_users || send_to_selected_users) && current_user.admin?

        errors.add(:base, :at_least_one_space) if spaces_selected.blank?
      end

      def other_groups_selected_for_all_users?
        send_to_verified_users.present? ||
          send_to_participants.present? ||
          send_to_followers.present? ||
          send_to_private_members.present? ||
          send_to_selected_users.present?
      end

      def other_groups_selected_for_verified_users?
        send_to_all_users.present? ||
          send_to_participants.present? ||
          send_to_followers.present? ||
          send_to_private_members.present? ||
          send_to_selected_users.present?
      end

      def only_followers_selected?
        send_to_all_users.blank? &&
          send_to_participants.blank? &&
          send_to_private_members.blank? &&
          send_to_verified_users.blank? &&
          send_to_selected_users.blank?
      end

      def only_participants_selected?
        send_to_all_users.blank? &&
          send_to_followers.blank? &&
          send_to_private_members.blank? &&
          send_to_verified_users.blank? &&
          send_to_selected_users.blank?
      end

      def only_private_members_selected?
        send_to_all_users.blank? &&
          send_to_followers.blank? &&
          send_to_participants.blank? &&
          send_to_verified_users.blank? &&
          send_to_selected_users.blank?
      end

      def only_selected_users_selected?
        send_to_all_users.blank? &&
          send_to_followers.blank? &&
          send_to_private_members.blank? &&
          send_to_participants.blank? &&
          send_to_verified_users.blank?
      end
    end
  end
end

Decidim::Admin::SelectiveNewsletterFormDecorator.decorate
