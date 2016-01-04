var elm_app;

$(function() {
  // Embed the elm app as a worker.
  elm_app = Elm.worker(Elm.Main, { problem: [2015, 1, ""] });
  elm_app.ports.answer.subscribe(display_aoc_answer);

  // Send a problem to the Elm app every time the menus update.
  $('#day').change(function() {
    var day = parseInt($(this).val(), 10);
    if (!isNaN(day)) solve_aoc_problem(2015, day);
  });
});

// Get the input for this problem, then send it, along with year and day, to the Elm app.
function solve_aoc_problem(year, day) {
  var file = '/aoc/' + year + '/' + day + '.txt';
  $.ajax({url: file}).done(function(text) {
    $('#input').val(text);
    elm_app.ports.problem.send([year, day, text]);
  });
}

// When the Elm app sends back a solution, display it.
function display_aoc_answer(output) {
  $('#answer').val(output);
}
