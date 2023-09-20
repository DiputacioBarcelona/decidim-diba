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

  def has_image?(attribute)
    return true unless model&.id

    newsletter.template.images_container.send(attribute).attached?
  end

  def header_logo_url(attribute, options = { resize_to_fill: [1200, 675] })
    return organization.attached_uploader(:logo).variant_url(:medium, host: organization.host) || organization.name unless model&.id

    representation_url(newsletter.template.images_container.send(attribute).variant(options))
  end

  private

  def representation_url(image)
    Rails.application.routes.url_helpers.rails_representation_url(image, host: organization.host)
  end
end
