import "stylesheets/newsletter.scss"

import TomSelect from "tom-select/dist/cjs/tom-select.popular";

$(() => {
  const $form = $(".form.newsletter_deliver");

  if ($form.length > 0) {
    const config = {
      plugins: ["remove_button", "dropdown_input"],
      allowEmptyOption: false
    };
    const multiselectFieldsContainers = document.querySelectorAll(
      ".newsletter_select-users"
    );

    multiselectFieldsContainers.forEach((container) => new TomSelect(container, config));

    const $sendNewsletterToFollowers = $form.find("#send_newsletter_to_followers");
    const $participatorySpacesForSelect = $form.find("#participatory_spaces_for_select");
    const $sendNewsletterToAllUsers = $form.find("#send_newsletter_to_all_users");
    const $sendNewsletterToParticipants = $form.find("#send_newsletter_to_participants");
    const $sendNewsletterToSelectUsers = $form.find("#newsletter_send_to_selected_users");
    const $usersSelect = $form.find(".newsletter_select-users");

    if ($sendNewsletterToSelectUsers.prop("checked")) {
      $usersSelect.css("display", "block");
    } else {
      $usersSelect.css("display", "none");
    }

    $sendNewsletterToAllUsers.on("change", (event) => {
      const checked = event.target.checked;
      $sendNewsletterToSelectUsers.prop("checked", !checked);

      if (checked) {
        $usersSelect.css("display", "none");
      } else {
        $usersSelect.css("display", "block");
      }
    });

    $sendNewsletterToFollowers.on("change", (event) => {
      const checked = event.target.checked;
      const selectiveNewsletterSelectUsers = $sendNewsletterToSelectUsers.prop("checked");

      if (checked) {
        $sendNewsletterToAllUsers.find("input[type='checkbox']").prop("checked", !checked);
        $participatorySpacesForSelect.show();
      } else if (selectiveNewsletterSelectUsers) {
        $sendNewsletterToAllUsers.find("input[type='checkbox']").prop("checked", false);
        $participatorySpacesForSelect.hide();
      }
    })

    $sendNewsletterToSelectUsers.on("change", (event) => {
      const checked = event.target.checked;
      const selectiveNewsletterParticipants = $sendNewsletterToParticipants.find("input[type='checkbox']").prop("checked");
      const selectiveNewsletterFollowers = $sendNewsletterToFollowers.find("input[type='checkbox']").prop("checked");

      if (checked) {
        $sendNewsletterToAllUsers.find("input[type='checkbox']").prop("checked", !checked);
        $usersSelect.css("display", "block");
      } else if (selectiveNewsletterParticipants || selectiveNewsletterFollowers) {
        $sendNewsletterToAllUsers.find("input[type='checkbox']").prop("checked", false);
        $usersSelect.css("display", "none");
      }
    })
  }
});
