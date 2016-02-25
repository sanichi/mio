$(function() {
  $('#reset').click(function(e) {
    e.preventDefault();
    $('#number').val('');
    $('#owner').val('');
    $(this).parents('form').submit();
  });
});
