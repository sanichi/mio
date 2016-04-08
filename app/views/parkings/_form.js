$(function() {
  $('#vehicle_id_completer').autocomplete({
    source: '/vehicles/match.json',
    minLength: 1,
    select: function(event, ui) {
      $('#parking_vehicle_id').val(ui.item ? ui.item.id : '');
      setTimeout(function() {
        $('#vehicle_id_completer').val('');
      }, 200);
    }
  });
  $('g.bay').click(function(e) {
    $('#parking_bay').val($(this).data('bay'));
  });
  $('g.road').click(function(e) {
    $('#parking_bay').val('0');
  });
});
