$(function() {
  $('#reset').click(function(e) {
    e.preventDefault();
    $('#registration').val('');
    $('#owner').val('');
    $(this).parents('form').submit();
  });
});
