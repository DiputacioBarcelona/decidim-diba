# frozen_string_literal: true

Deface::Override.new(
  virtual_path: "decidim/forms/admin/questionnaires/_question",
  name: "add_sortable_to_question",
  add_to_attributes: "div.card-divider",
  original: "ef8357c1edb2c62d7e994cdd0dc7ae00a9f38f29",
  attributes: { class: "question-divider" }
)

Deface::Override.new(
  virtual_path: "decidim/forms/admin/questionnaires/_separator",
  name: "add_sortable_to_separator",
  add_to_attributes: "div.card-divider",
  original: "8c8187cdecc37c3c1c7504d298a6b40e1912b9b9",
  attributes: { class: "question-divider" }
)

Deface::Override.new(
  virtual_path: "decidim/forms/admin/questionnaires/_title_and_description",
  name: "add_sortable_to_title_and_description",
  add_to_attributes: "div.card-divider",
  original: "71be165099cc0d2bc000bed6281b81d427f2d578",
  attributes: { class: "question-divider" }
)

Deface::Override.new(
  virtual_path: "decidim/meetings/admin/poll/_question",
  name: "add_sortable_to_poll_question",
  add_to_attributes: "div.card-divider",
  original: "76f4bc9860f4bc088c60d035551a695828d2b209",
  attributes: { class: "question-divider" }
)
