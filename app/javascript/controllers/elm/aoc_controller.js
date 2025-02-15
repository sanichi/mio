import { Controller } from "@hotwired/stimulus"
import { Elm } from "elm_aoc"

export default class extends Controller {
  connect() {
    const app = Elm.Main.init({
      node: this.element,
      flags: {
        year: '<%= year %>',
        day: '<%= day %>'
      }
    });
    app.ports.getData.subscribe(function(yd) {
      var year = yd[0];
      var day  = yd[1];
      var file = '/aoc/' + year + '/' + day + '.txt';
      $.ajax({
        url: file,
        dataType: 'text'
      }).done(function(data) {
        app.ports.gotData.send(data);
      });
    });
    app.ports.getRuby.subscribe(function(ydp) {
      $.ajax({
        url: '/ruby',
        data: {
          year: ydp[0],
          day:  ydp[1],
          part: ydp[2]
        },
        dataType: 'text'
      }).done(function(answer) {
        app.ports.gotRuby.send([ydp[2], answer]);
      });
    });
    app.ports.doPause.subscribe(function(part) {
      // this timeout is here so elm will pause long enough to display
      // the "thinking" gif before it starts calculating the answer
      setTimeout(function() {
        app.ports.donePause.send(part);
      }, 100);
    });
  }
}
