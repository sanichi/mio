$(function() {
  $('#person_id_completer').autocomplete({
    source: '/people/match.json',
    minLength: 2,
    select: function(event, ui) {
      $('#picture_person_id').val(ui.item ? ui.item.id : '');
      setTimeout(function() {
        $('#person_id_completer').val('');
      }, 200);
    }
  });
});
