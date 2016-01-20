var elm_app;

$(function() {
  // Embed the elm app as a worker.
  elm_app = Elm.worker(Elm.Main, { problem: [2015, 1, ''] });
  elm_app.ports.answer.subscribe(display_aoc_answer);

  // Send a problem to the Elm app every time the menus update.
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
  $('#answer').val('');
  $('#input').val('');
  $('#code').hide();
  $('#loading').hide();
  if (!isNaN(day) && !isNaN(year))
  {
    var file = '/aoc/' + year + '/' + day + '.txt';
    $.ajax({url: file}).done(function(text) {
      $('#input').val(text);
      $('#loading').show();
      $('#code').attr('href', code_link(year, day));
      $('#code').show();
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

// Link to code for given year and day.
function code_link(year, day) {
  var yy = year.toString().substring(2, 4);
  var dd = (day < 10 ? '0' : '') + day;
  return 'https://bitbucket.org/sanichi/sni_mio_app/src/5f9048c84102cdb8eff1c23c91c1a571c19234b5/app/views/pages/aoc/' + year + '/Y' + yy + 'D' + dd + '.elm?at=master&fileviewer=file-view-default';
}
