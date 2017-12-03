$(function() {
  $('#reveal-button').click(function() {
    $('.masked').each(function (i, e) {
      $(this).text($(this).data('unmasked'));
    });
    $('#reveal-button').hide();
    $('#skip-button').hide();
    $('#redo-button').hide();
    $('#success-button').show();
    $('#failure-button').show();
    $('#answer').slideDown(800);
  });
  $('#success-button').click(function() {
    $('#kanji_question_answer').val('true');
    $('#question-form').submit();
  });
  $('#failure-button').click(function() {
    $('#kanji_question_answer').val('false');
    $('#question-form').submit();
  });
});
