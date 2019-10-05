function play_audio(audio_id, reading_id) {
  $('#audio_' + audio_id).get(0).play();
  var button = $('#audio_button_' + audio_id);
  var button_next = button.nextAll('button.reading_' + reading_id);
  var button_prev = button.prevAll('button.reading_' + reading_id);
  if (button_next.length > 0) {
    button.hide();
    button_next.first().show();
    button_next.first().get(0).focus();
  } else if (button_prev.length > 0) {
    button.hide();
    button_prev.first().show();
    button_prev.first().get(0).focus();
  }
}
