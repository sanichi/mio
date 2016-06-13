$(function() {
  $('#reset').click(function(e) {
    e.preventDefault();
    $('#name').val('');
    $('#notes').val('');
    $('#order').val('name');
    $('#done').val('');
    $(this).parents('form').submit();
  });
});
