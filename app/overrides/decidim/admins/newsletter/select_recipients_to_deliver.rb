# frozen_string_literal: true

Deface::Override.new(virtual_path: "decidim/admin/newsletters/select_recipients_to_deliver",
                     name: "add_new_user_segmentation",
                     insert_after: ".grid-padding-x:last-child",
                     text: '
                        <%= render partial: "select_single_users", locals: { f: f } %>
                      ')
