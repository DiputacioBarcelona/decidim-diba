# frozen_string_literal: true

unless ActiveModel::Type::Boolean.new.cast(ENV.fetch("DOCKER", nil))
  Deface::Override.new(virtual_path: "decidim/admin/newsletters/select_recipients_to_deliver",
                       name: "add_new_user_segmentation",
                       insert_after: "div#send_newsletter_to_participants",
                       original: "e5a692c0a681a7bd3160ee02d18e000963d40ddd",
                       text: '
                        <%= render partial: "select_single_users", locals: { f: f } %>
                      ')
end
