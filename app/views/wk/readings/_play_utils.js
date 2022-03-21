$(function () {
  $('#accent_updates').on('click', 'button.audio_button', function (e) {
    // play the audio
    var button = $(e.target);
    var audio_id = button.data('audio');
    $('#audio_' + audio_id).get(0).play();
    // switch the active audio
    var reading_id = button.data('reading');
    var button_next = button.nextAll('button.reading_' + reading_id);
    var button_prev = button.prevAll('button.reading_' + reading_id);
    if (button_next.length > 0) {
      button.addClass('d-none');
      button_next.first().removeClass('d-none');
      button_next.first().get(0).focus();
    } else if (button_prev.length > 0) {
      button.addClass('d-none');
      button_prev.first().removeClass('d-none');
      button_prev.first().get(0).focus();
    }
  });
});
