$(function() {
  $('#reset').click(function(e) {
    e.preventDefault();
    $('#first_names').val('');
    $('#last_name').val('');
    $('#block').val('');
    $('#flat').val('');
    $('#bay').val('');
    $(this).parents('form').submit();
  });
});
