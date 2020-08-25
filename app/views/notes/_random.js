$(function() {
  $('#show').on('click', function(e) {
    // show the answer
    $('#answer').show();
    var button = $(e.target);
    // hide the button's parent
    button.parent().hide();
  });
});
