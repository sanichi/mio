$(function() {
  $('#reset').click(function(e) {
    e.preventDefault();
    $('#vehicle').val('');
    $('#bay').val('');
    $(this).parents('form').submit();
  });
  $(function() {
    $('g.bay').click(function(e) {
      $('#bay').val($(this).data('bay')).parents('form').submit();
    });
  });
});
