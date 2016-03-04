$(function() {
  $('#reset').click(function(e) {
    e.preventDefault();
    $('#first_names').val('');
    $('#last_name').val('');
    $(this).parents('form').submit();
  });
});
