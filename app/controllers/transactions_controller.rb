class TransactionsController < ApplicationController
  authorize_resource

  def index
    @transactions = Transaction.search(params, transactions_path, remote: true)
  end

  def show
    @transaction = Transaction.find(params[:id])
  end

  def summary
    @summary = TransactionSummary.new
  end
end
