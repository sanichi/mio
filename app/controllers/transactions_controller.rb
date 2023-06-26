class TransactionsController < ApplicationController
  authorize_resource
  load_resource only: :quick_approval_update

  def index
    @transactions, @corrections = Transaction.search(params, transactions_path, per_page: 20, remote: true)
  end

  def upload
    file = params[:file]
    upload_id = Transaction.last_upload_id + 1
    begin
      raise "no file" unless file.is_a?(ActionDispatch::Http::UploadedFile)
      raise "wrong file type (#{file.content_type})" unless file.content_type == "text/csv"
      flash[:notice] = Transaction.upload(file.path, upload_id)
    rescue => e
      flash[:alert] = e.message
    ensure
      redirect_to transactions_path(upload_id: upload_id)
    end
  end

  def quick_approval_update
    @transaction.toggle_approved
    render :quick_approval_update, layout: false
  end
end
