$(function() {
  $('.bay.btn').click(function(e) {
    $('#parking_bay').val($(this).data('bay'));
  });
});
