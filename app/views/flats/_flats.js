$(function() {
  $('#reset').click(function(e) {
    e.preventDefault();
    $('#building').val('');
    $('#number').val('');
    $('#block').val('');
    $('#bay').val('');
    $('#category').val('');
    $('#name').val('');
    $(this).parents('form').submit();
  });
});
