$(function() {
  $('#husband_id_completer').autocomplete({
    source: '/people/match.json?gender=male',
    minLength: 2,
    select: function(event, ui) {
      $('#partnership_husband_id').val(ui.item ? ui.item.id : '');
      setTimeout(function() {
        $('#husband_id_completer').val('');
      }, 200);
    }
  });
  $('#wife_id_completer').autocomplete({
    source: '/people/match.json?gender=female',
    minLength: 2,
    select: function(event, ui) {
      $('#partnership_wife_id').val(ui.item ? ui.item.id : '');
      setTimeout(function() {
        $('#wife_id_completer').val('');
      }, 200);
    }
  });
});
