$(function() {
  var node = document.getElementById("elm");
  var app = Elm.Main.embed(node);
  app.ports.random_request.subscribe(function() {
    var answer = Math.floor((Math.random() * 8 + 1));
    app.ports.random_response.send(answer);
  });
});
