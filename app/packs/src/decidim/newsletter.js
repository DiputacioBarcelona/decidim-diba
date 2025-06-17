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
    const $copySelectedUsers = $form.find(".newsletter_copy-selected-users");
    const switchVisibility = (visible, selectors) => {
      if (visible) {
        selectors.forEach((selector) => {
          selector.css("display", "block");
        });

      } else {
        selectors.forEach((selector) => {
          selector.css("display", "none");
        });
      }
    }

    switchVisibility($sendNewsletterToSelectUsers.prop("checked"), [$usersSelect, $copySelectedUsers])

    $sendNewsletterToAllUsers.on("change", (event) => {
      const checked = event.target.checked;
      $sendNewsletterToSelectUsers.prop("checked", !checked);
      switchVisibility(checked, [$usersSelect, $copySelectedUsers])
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

      switchVisibility(checked, [$usersSelect, $copySelectedUsers])

      if (checked) {
        $sendNewsletterToAllUsers.find("input[type='checkbox']").prop("checked", !checked);
      } else if (selectiveNewsletterParticipants || selectiveNewsletterFollowers) {
        $sendNewsletterToAllUsers.find("input[type='checkbox']").prop("checked", false);
      }
    })

    $copySelectedUsers.find("select").on("change", (event) => {
      const newsletterId = event.target.value;

      $.ajax({
        type: "get",
        url: `/newsletter_settings?newsletter_id=${newsletterId}`,
        success: (response) => {
          const tomselect = document.getElementById("newsletter_selected_users_ids").tomselect;
          $usersSelect.val(response.message);
          tomselect.sync();
        }
      });
    })
  }
});
