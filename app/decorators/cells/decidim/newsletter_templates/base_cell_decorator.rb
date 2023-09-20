# frozen_string_literal: true

Decidim::NewsletterTemplates::BaseCell.class_eval do
  def header_background_color
    model.settings.header_background_color.presence || "#1a181d"
  end

  def body_background_color
    model.settings.body_background_color.presence || "#fefefe"
  end

  def body_font_color
    model.settings.body_font_color.presence || "#00000"
  end
end
