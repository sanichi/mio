$(function() {
  $('#click-all-links').click(function() {
    $('.external-link').each(function (i, e) {
      e.click();
    });
  });
});
