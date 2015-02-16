class UploadsController < ApplicationController
  authorize_resource

  def index
    @uploads = Upload.search(params, uploads_path)
  end

  def show
    @upload = Upload.find(params[:id])
    @transactions = @upload.transactions
  end

  def new
    @upload = Upload.new
  end

  def create
    @upload = Upload.new(strong_params)
    if @upload.save
      redirect_to @upload
    else
      render "new"
    end
  end

  def destroy
    Upload.find(params[:id]).destroy
    redirect_to uploads_path
  end

  private

  def strong_params
    params.require(:upload).permit(:account, :file)
  end
end
