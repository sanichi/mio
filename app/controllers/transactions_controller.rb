class TransactionsController < ApplicationController
  def index
    @transactions = Transaction.search(params, transactions_path)
  end

  def show
    @transaction = Transaction.find(params[:id])
  end

  def summary
    @summary = TransactionSummary.new
  end
end
