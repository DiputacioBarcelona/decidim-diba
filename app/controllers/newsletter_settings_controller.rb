# frozen_string_literal: true

class NewsletterSettingsController < ApplicationController
  def show
    user = Decidim::User.find(params[:user_id])

    if user.newsletter_notifications_at.present?
      render json: { message: "ok", status: 200 }
    else
      render json: { message: t(".user_without_newsletter_settings"), status: 403 }
    end
  end
end
