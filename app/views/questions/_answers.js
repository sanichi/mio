$(function() {
  $('#question').on('mouseenter', 'li.correct-answer', function() {
    $(this).addClass("text-light bg-dark");
  });
  $('#question').on('mouseout', 'li.correct-answer', function() {
    $(this).removeClass("text-light bg-dark");
  });
});
