# frozen_string_literal: true

module Decidim::Admin::NewslettersHelperDecorator
  def self.decorate
    Decidim::Admin::NewslettersHelper.class_eval do
      alias_method :original_sent_to_users, :sent_to_users

      def sent_to_users(newsletter)
        if newsletter.sended_to_selected_users?
          tag.p(style: "margin-bottom:0;") do
            concat tag.strong(t("index.has_been_sent_to", scope: "decidim.admin.newsletters"), class: "text-success")
            concat tag.strong(t("index.selected_users", scope: "decidim.admin.newsletters"))
          end
        else
          original_sent_to_users(newsletter)
        end
      end
    end
  end
end

::Decidim::Admin::NewslettersHelperDecorator.decorate
