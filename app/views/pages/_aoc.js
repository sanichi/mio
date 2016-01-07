var elm_app;

$(function() {
  // Embed the elm app as a worker.
  elm_app = Elm.worker(Elm.Main, { problem: [2015, 1, ""] });
  elm_app.ports.answer.subscribe(display_aoc_answer);

  // See if we can send a problem to the Elm app every time the menus update.
  $('#year').change(function() {
    solve_aoc_problem($(this).val(), $('#day').val());
  });
  $('#day').change(function() {
    solve_aoc_problem($('#year').val(), $(this).val());
  });
});

// Check both a year and a day are selected and if so, get the input
// for the problem and send it, along with year and day, to the Elm app.
function solve_aoc_problem(y, d) {
  var year = parseInt(y, 10);
  var day  = parseInt(d, 10);
  if (!isNaN(day) && !isNaN(year))
  {
    var file = '/aoc/' + year + '/' + day + '.txt';
    $.ajax({url: file}).done(function(text) {
      $('#input').val(text);
      $('#loading').show();
      setTimeout(function() { // flush DOM changes
        elm_app.ports.problem.send([year, day, text]);
      }, 10);
    });
  }
}

// When the Elm app sends back a solution, display it.
function display_aoc_answer(output) {
  $('#answer').val(output);
  $('#loading').hide();
}
