# frozen_string_literal: true

module Decidim::Admin::SelectiveNewsletterFormDecorator
  def self.decorate
    Decidim::Admin::SelectiveNewsletterForm.class_eval do
      # Remove original validators
      attributes = [:send_to_all_users, :send_to_followers, :send_to_participants]

      attributes.each do |attribute|
        _validators.delete(attribute)
      end

      _validate_callbacks.each do |callback|
        next unless callback.raw_filter.respond_to? :attributes

        attributes.each do |attribute|
          callback.raw_filter.attributes.delete attribute
        end
      end

      attribute :selected_users_ids, Array
      attribute :send_to_selected_users, Virtus::Attribute::Boolean

      validates :send_to_all_users, presence: true, unless: ->(form) { form.send_to_participants.present? || form.send_to_followers.present? || form.send_to_selected_users.present? }

      # Set new validations with the new attribute
      validates :send_to_followers, presence: true, if: ->(form) { form.send_to_all_users.blank? && form.send_to_participants.blank? && form.send_to_selected_users.blank? }
      validates :send_to_participants, presence: true, if: ->(form) { form.send_to_all_users.blank? && form.send_to_followers.blank? && form.send_to_selected_users.blank? }
      validates :send_to_selected_users, presence: true, if: ->(form) { form.send_to_all_users.blank? && form.send_to_participants.blank? && form.send_to_followers.blank? }

      private

      def at_least_one_participatory_space_selected
        return if send_to_all_users && current_user.admin? || send_to_selected_users

        errors.add(:base, :at_least_one_space) if spaces_selected.blank?
      end
    end
  end
end

::Decidim::Admin::SelectiveNewsletterFormDecorator.decorate
