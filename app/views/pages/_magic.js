$(function() {
  var node = $('#elm-app').get(0);
  var app = Elm.Main.embed(node);
  app.ports.waitAMoment.subscribe(function() {
    setTimeout(function() {
      app.ports.continue.send(null);
    }, 100);
  });
});