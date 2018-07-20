$(function() {
  $('.accent_updater').keypress(function(e) {
    var id = $(e.target).data('id');
    var code = e.keyCode;
    var accent = '';
    if (code == 45) {
      accent = '-';
    } else if (code == 63) {
      accent = '?';
    } else if (code >= 48 && code <= 57) {
      accent = (code - 48).toString();
    }
    if (accent.length == 1) {
      $.ajax({
        url: '/vocabs/' + id + '/quick_accent_update',
        type: 'patch',
        data: { accent: accent }
      });
    }
  });
});
