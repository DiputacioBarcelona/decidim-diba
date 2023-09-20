# frozen_string_literal: true

Rails.application.config.after_initialize do
  Decidim.content_blocks.for(:newsletter_template).each do |cb|
    cb.settings do |settings|
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
  end
end
