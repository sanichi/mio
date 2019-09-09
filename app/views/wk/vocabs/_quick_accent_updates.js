$(function() {
  $('#accent_updates').on('keypress', '.accent_updater', function(e) {
    var id = $(e.target).data('id');
    var code = e.keyCode;
    var accent = '';
    if (code == 45) {
      // - (meaning tried but couldn't find out)
      accent = '-';
    } else if (code == 63) {
      // ? (meaning not yet known)
      accent = '?';
    } else if (code >= 48 && code <= 57) {
      // 0-9
      accent = (code - 48).toString();
    } else if (code >= 65 && code <= 71) {
      // A-J which we use to signal 10-16 (note the longest WK reading is 11)
      accent = (code - 55).toString();
    } else if (code >= 97 && code <= 103) {
      // a-j, same as above
      accent = (code - 87).toString();
    }
    if (accent.length == 1 || accent.length == 2) {
      $.ajax({
        url: '/wk/vocabs/' + id + '/quick_accent_update',
        type: 'patch',
        data: { accent: accent }
      });
    }
  });
});
