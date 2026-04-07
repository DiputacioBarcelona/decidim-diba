# frozen_string_literal: true

unless ActiveModel::Type::Boolean.new.cast(ENV.fetch("DOCKER", nil))
  Deface::Override.new(virtual_path: "decidim/admin/newsletters/confirm_recipients",
                       name: "insert_users_selection_hidden_fields",
                       insert_before: "erb[loud]:contains('submit_tag')",
                       original: "e5a692c0a681a7bd3160ee02d18e000963d40ddd",
                       text: '
                        <%= render partial: "users_selection_hidden_fields", locals: { f: f } %>
                      ')
end
