$(function() {
  // Reset button.
  $('#reset').click(function(e) {
    e.preventDefault();
    $('#term').val('');
    $('#vehicle').val('');
    $('#bay').val('');
    $(this).parents('form').submit();
  });
  // Click on bays.
  $('g.bay').click(function(e) {
    $('#bay').val($(this).data('bay')).parents('form').submit();
  });
  // Click on roads.
  $('g.road').click(function(e) {
    $('#bay').val('0').parents('form').submit();
  });
  // Auto-completer for vehicles.
  $('input[name="term"]').autocomplete({
    source: '/vehicles/match.json',
    minLength: 1,
    select: function(event, ui) {
      $('#vehicle').val(ui.item ? ui.item.id : '').parents('form').submit();
      setTimeout(function() {
        $('input[name="term"]').val('');
      }, 200);
    }
  });
  // Intelligently guess what "New Parking" should do.
  $('a[href^="/parkings/new"]').attr('href','<%= guess_next_parking(@parkings.matches) %>');
});
