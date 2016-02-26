$(function() {
  $('.bay.btn').click(function(e) {
    $('#parking_bay_id').val($(this).data('bay'));
  });
});
