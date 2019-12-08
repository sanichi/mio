class BucketsController < ApplicationController
  authorize_resource
  before_action :find_bucket, only: [:edit, :update, :show, :destroy]

  def index
    remember_last_path(:buckets)
    @buckets = Bucket.search(params)
  end

  def new
    @bucket = Bucket.new
  end

  def create
    @bucket = Bucket.new(strong_params)
    if @bucket.save
      redirect_to @bucket
    else
      failure @bucket
      render :new
    end
  end

  def update
    if @bucket.update(strong_params)
      redirect_to @bucket
    else
      failure @bucket
      render :edit
    end
  end

  def destroy
    @bucket.destroy
    redirect_to buckets_path
  end

  private

  def find_bucket
    @bucket = Bucket.find(params[:id])
  end

  def strong_params
    params.require(:bucket).permit(:mark, :name, :notes, :sandra)
  end
end
