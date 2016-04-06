$(function() {
  $('#reset').click(function(e) {
    e.preventDefault();
    $('#vehicle').val('');
    $('#bay').val('');
    $(this).parents('form').submit();
  });
  $('g.bay').click(function(e) {
    $('#bay').val($(this).data('bay')).parents('form').submit();
  });
  $('g.road').click(function(e) {
    $('#bay').val('0').parents('form').submit();
  });
});
