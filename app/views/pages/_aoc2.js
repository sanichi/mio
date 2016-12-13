$(function() {
  var app = Elm.Main.embed($('#elm-app').get(0));
  app.ports.getData.subscribe(function(year_day) {
    var year = year_day[0];
    var day = year_day[1];
    var file = '/aoc/' + year + '/' + day + '.txt';
    $.ajax({url: file}).done(function(data) {
      app.ports.newData.send(data);
    });
  });
  app.ports.prepareAnswer.subscribe(function(part) {
    setTimeout(function() {
      app.ports.startAnswer.send(part);
    }, 100);
  });
});
