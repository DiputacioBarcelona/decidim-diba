$(document).ready(function() {
  $('.newsletter_select-users').select2();
  
  $('.newsletter_select-users').on('select2:select', function (e) {
    let data = e.params.data;
    let userId = data.id;

    $.ajax({
      type: "get",
      url: `/newsletter_settings?user_id=${userId}`,
      success: (response) => {
        if (response.status === 403) {
          $(this).val(null).trigger('change');
        }
      },
    });
  });

  const $form = $(".form.newsletter_deliver");

  if ($form.length > 0) {
    const $sendNewsletterToFollowers = $form.find("#send_newsletter_to_followers");
    const $participatorySpacesForSelect = $form.find("#participatory_spaces_for_select");
    const $sendNewsletterToAllUsers = $form.find("#send_newsletter_to_all_users");
    const $sendNewsletterToParticipants = $form.find("#send_newsletter_to_participants");
    const $sendNewsletterToSelectUsers = $form.find("#send_newsletter_to_select_users");

    $sendNewsletterToAllUsers.on("change", (event) => {
      const checked = event.target.checked;
      $sendNewsletterToSelectUsers.find("input[type='checkbox']").prop("checked", !checked);
    })

    $sendNewsletterToFollowers.on("change", (event) => {
      const checked = event.target.checked;
      const selectiveNewsletterSelectUsers = $sendNewsletterToSelectUsers.find("input[type='checkbox']").prop("checked");

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
      } else if (selectiveNewsletterParticipants || selectiveNewsletterFollowers) {
        $sendNewsletterToAllUsers.find("input[type='checkbox']").prop("checked", false);
      }
    })
  }
});
