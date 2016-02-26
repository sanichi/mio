$(function() {
  $('#reset').click(function(e) {
    e.preventDefault();
    $('#vehicle').val('');
    $('#bay').val('');
    $(this).parents('form').submit();
  });
});
