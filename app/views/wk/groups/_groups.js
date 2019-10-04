$(function() {
  // Reset button.
  $('#reset').click(function(e) {
    e.preventDefault();
    $('#category').val('');
    $('#query').val('');
    $(this).parents('form').submit();
  });
});
