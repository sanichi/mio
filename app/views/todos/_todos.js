var div = $('#elm').get(0);
var todos = Elm.embed(Elm.Main, div, {getAuthToken: ""});
var token = $("meta[name='csrf-token']").attr('content') || "no-token-available";
todos.ports.getAuthToken.send(token);
function log(x) { console.log(x) }
todos.ports.logUpdates.subscribe(log);
