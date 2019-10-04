$(function() {
  // Reset button.
  $('#reset').click(function(e) {
    e.preventDefault();
    $('#query').val('');
    $(this).parents('form').submit();
  });
});
