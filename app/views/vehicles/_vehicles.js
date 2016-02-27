$(function() {
  $('#reset').click(function(e) {
    e.preventDefault();
    $('#registration').val('');
    $('#description').val('');
    $('#owner').val('');
    $(this).parents('form').submit();
  });
});
