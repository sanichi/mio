$(function () {
  var app = Elm.Main.init({
    node: document.getElementById("elm"),
    flags: {
      current_year: new Date().getFullYear(),
    }
  });
  app.ports.random_request.subscribe(function () {
    var answer = Math.floor((Math.random() * 8 + 1));
    app.ports.random_response.send(answer);
  });
});
