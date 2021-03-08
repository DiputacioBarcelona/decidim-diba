# frozen_string_literal: true

unless ActiveModel::Type::Boolean.new.cast(ENV["DOCKER"])
  Deface::Override.new(virtual_path: "decidim/consultations/questions/_vote_modal_confirm",
                       name: "add_remote_in_vote_modal_confirm",
                       replace: "erb[loud]:contains('form_with url: decidim_consultations.question_question_votes_path(question)')",
                       text: "
                        <%= form_with url: decidim_consultations.question_question_votes_path(question), id: 'confirm-vote-form', data: {remote: true} do |form| %>
                     ")
end
