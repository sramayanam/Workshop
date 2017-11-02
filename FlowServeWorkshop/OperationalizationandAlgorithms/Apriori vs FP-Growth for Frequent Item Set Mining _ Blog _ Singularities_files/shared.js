(function() {
  $(function() {

    $(document).foundation();

    $(".full_screen_box_w_centered_content").load(function() {
      var content;
      content = $(this).find(".content");
      content.css("margin-left", "-" + (window.innerWidth / 2) + "px");
      content.css("margin-top", "-" + (content.height() / 2) + "px");
      content.find(".text-center").css("visibility", "visible");
      return $(window).resize(function() {
        content.css("margin-left", "-" + (window.innerWidth / 2) + "px");
        return content.css("margin-top", "-" + (content.height() / 2) + "px");
      });
    }).trigger("load");

  });
}).call(this);


$(document).ready(function(){
  $('.contact-form').attr('data-abide', '');

  $('.contact-form #contact_email').addClass('modal-body');
  $('.contact-form #contact_email').removeAttr('value');
  $('.contact-form #contact_email').removeClass('email');
  $('.contact-form #contact_email').attr('type', 'email');
  $('.contact-form #contact_email').attr('placeholder', "Email");
  $('.contact-form #contact_email').prop('required', true);

  $('.contact-form #contact_message').addClass('modal-body');
  $('.contact-form #contact_message').removeClass('message');
  $('.contact-form #contact_message').attr('type', 'email');
  $('.contact-form #contact_message').attr('placeholder', 'Message');
  $('.contact-form #contact_message').attr('rows', '6');
  $('.contact-form #contact_message').prop('required', true);


  $('#contact > form > span > input[type="submit"]').addClass('button');

  $('.email-error.error').css('display', 'none');
  $('.message-error.error').css('display', 'none');
});
