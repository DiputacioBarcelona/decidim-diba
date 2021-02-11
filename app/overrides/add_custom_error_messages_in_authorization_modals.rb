<<<<<<< HEAD
Deface::Override.new(virtual_path: 'decidim/authorization_modals/_content',
                     name: 'add_custom_error_messages_in_authorization_modals',
                     replace: '<li>',
=======
Deface::Override.new(virtual_path: 'layouts/decidim/_wrapper',
                     name: 'radd_custom_error_messages_in_authorization_modals',
                     replace: '<li><strong><%= t ".#{status.code}.invalid_field", field: t("#{status.handler_name}.fields.#{field}", scope: "decidim.authorization_handlers"), value: value ? "(#{value})" : "" %></strong></li>',
>>>>>>> Change some overrides with Deface
                     text: '
                      <% case field %>
                        <% when :birthdate %>
                          <li> <strong> <%= text_invalid_age_authorizer(status) %> </strong> </li>
                        <% when :subcensus %>
                          <li> <strong> <%= t(".subcensus.invalid_field", scope: "diba")%> </strong> </li>
                        <% else %>
                          <li><strong><%= t ".#{status.code}.invalid_field", field: t("#{status.handler_name}.fields.#{field}", scope: "decidim.authorization_handlers"), value: value ? "(#{value})" : "" %></strong></li>
                        <% end %>
                     ')
