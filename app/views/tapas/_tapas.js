$(function() {
  // When the reset button in the form is clicked.
  $('#reset').click(function(e) {
    e.preventDefault();
    $('#number').val('');
    $('#query').val('');
    $('#star').val('');
    $(this).parents('form').submit();
  });

  // When one of the notes buttons is pressed.
  $('#notes').on('show.bs.modal', function (event) {
    var button = $(event.relatedTarget);
    var id = button.data('id');
    var number = button.data('number');
    var modal = $(this);
    modal.find('#notes-title').text('Notes for Ruby Tapas ' + number);
    modal.find('.modal-body').html('');
    $.ajax({url: '/tapas/' + id + '/notes'}).done(function(notes) {
      modal.find('.modal-body').html(notes);
    });
  });
});
