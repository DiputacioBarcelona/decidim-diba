# frozen_string_literal: true

module Decidim::Admin::SelectiveNewsletterFormDecorator
  def self.decorate
    Decidim::Admin::SelectiveNewsletterForm.class_eval do
      attribute :selected_users_ids, Array
      attribute :send_to_selected_users, Virtus::Attribute::Boolean

      validates :send_to_selected_users, presence: true, unless: ->(form) { form.send_to_all_users.blank? }
    end
  end
end

::Decidim::Admin::SelectiveNewsletterFormDecorator.decorate
