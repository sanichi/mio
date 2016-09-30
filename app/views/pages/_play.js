$(function() {
  var nod = document.getElementById("elm");
  var app = Elm.Main.embed(nod);
  // app.ports.random_request.subscribe(function() {
  //   var answer = Math.floor((Math.random() * 10) + 1);
  //   app.ports.random_response.send(answer);
  // });
});
