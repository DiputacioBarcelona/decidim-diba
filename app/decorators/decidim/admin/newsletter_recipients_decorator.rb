# frozen_string_literal: true

module Decidim::Admin::NewsletterRecipientsDecorator
  def self.decorate
    Decidim::Admin::NewsletterRecipients.class_eval do
      alias_method :original_query, :query

      def query
        if @form.send_to_selected_users
          recipients = selected_users

          followers = recipients.where(id: user_id_of_followers) if @form.send_to_followers
          participants = recipients.where(id: participant_ids) if @form.send_to_participants

          recipients = (followers + participants + selected_users).uniq if @form.send_to_followers && @form.send_to_participants

          recipients
        else
          original_query
        end
      end

      private

      def selected_users
        Decidim::User.where(id: @form.selected_users_ids, organization: @form.current_organization)
      end
    end
  end
end

::Decidim::Admin::NewsletterRecipientsDecorator.decorate
