// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery-ui/autocomplete
//= require jquery_ujs
//= require bootstrap.min

$(function() {
  // Auto-submit on change.
  $('form .auto-submit').change(function() {
    $(this).parents('form').submit();
  });
  // Keyboard pagination.
  $(document).keydown(function(event) {
    switch (event.which) {
      case 37:
        $('a#pagn_prev').trigger('click');
        break;
      case 38:
        $('a#pagn_frst').trigger('click');
        break;
      case 39:
        $('a#pagn_next').trigger('click');
        break;
      case 40:
        $('a#pagn_last').trigger('click');
        break;
    }
  });
});
