$(function () {
  $('#results').on('click', 'button.approval-button', function (e) {
    var transaction_id = $(e.target).data('transaction');
    $.ajax({
      url: '/transactions/' + transaction_id + '/quick_approval_update',
      type: 'patch'
    }).done(function (json) {
      $(e.target).text(json.text);
    });
  });
});
