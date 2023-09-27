# frozen_string_literal: true

Rails.application.config.after_initialize do
  Decidim.content_blocks.for(:newsletter_template).each do |content_block|
    content_block.settings do |settings|
      settings.attribute(
        :header_background_color,
        type: :text
      )

      settings.attribute(
        :body_background_color,
        type: :text
      )

      settings.attribute(
        :body_font_color,
        type: :text
      )
    end

    if content_block.name == :basic_only_text
      content_block.images = [header_logo]
    else
      content_block.images << header_logo
    end
  end
end

def header_logo
  {
    name: :header_logo,
    uploader: "Decidim::NewsletterTemplateImageUploader",
    preview: -> { ActionController::Base.helpers.asset_pack_path("media/images/placeholder.jpg") }
  }
end
