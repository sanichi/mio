$(function() {
  $('g.bay').click(function(e) {
    $('#parking_bay').val($(this).data('bay'));
  });
  $('g.road').click(function(e) {
    $('#parking_bay').val('0');
  });
});
