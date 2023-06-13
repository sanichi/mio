class TransactionsController < ApplicationController
  authorize_resource

  def index
    @transactions = Transaction.search(params, transactions_path, per_page: 2, remote: true)
  end
end
