$(function() {
  var app = Elm.Main.init({
    node: $('#elm-app').get(0)
  });
  app.ports.waitAMoment.subscribe(function() {
    setTimeout(function() {
      app.ports.continue.send(null);
    }, 100);
  });
});
