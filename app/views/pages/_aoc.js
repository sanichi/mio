$(function() {
  $('#day').change(function() {
    var day = $(this).val();
    get_aoc_input(2015, day);
  });
  Elm.worker(Elm.Main);
});

function get_aoc_input(year, day) {
  var file = '/aoc/' + year + '/' + day + '.txt';
  $.ajax({url: file}).done(function(text) {
    $('#input').val(text);
  });
}
