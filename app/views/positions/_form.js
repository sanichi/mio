$(function() {
  $('#opening_id_completer').autocomplete({
    source: '/openings/match.json',
    minLength: 2,
    select: function(event, ui) {
      $('#position_opening_id').val(ui.item ? ui.item.id : '');
      setTimeout(function() {
        $('#opening_id_completer').val('');
      }, 200);
    }
  });
});
