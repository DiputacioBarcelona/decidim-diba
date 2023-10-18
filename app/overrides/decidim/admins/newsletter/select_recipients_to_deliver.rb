# frozen_string_literal: true

Deface::Override.new(virtual_path: "decidim/admin/newsletters/select_recipients_to_deliver",
                     name: "add_new_user_segmentation",
                     insert_after: ".grid-padding-x:last-child",
                     original: "27433f49f16b5a28709d507f1fe5c781022b15e8",
                     text: '
                        <%= render partial: "select_single_users", locals: { f: f } %>
                      ')
