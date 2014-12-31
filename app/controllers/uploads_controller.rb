class UploadsController < ApplicationController
  def index
    @uploads = Upload.all
  end

  def show
    @upload = Upload.find(params[:id])
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
    params[:upload] ||= { file: nil }
    params.require(:upload).permit(:file)
  end
end
