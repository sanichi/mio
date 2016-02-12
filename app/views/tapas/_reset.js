$(function() {
  $('#reset').click(function(e) {
    e.preventDefault();
    $('#number').val('');
    $('#query').val('');
    $(this).parents('form').submit();
  });
});
