class PicturesController < ApplicationController
  authorize_resource
  before_action :find_picture, only: [:show, :edit, :update, :destroy]

  def index
    @pictures = Picture.search(params)
    prev_next(:picture_ids, @pictures)
  end

  def new
    person_id = params[:person_id].to_i
    person_id = nil unless person_id > 0 && Person.find_by(id: person_id)
    @picture = Picture.new(person_id: person_id)
  end

  def create
    @picture = Picture.new(strong_params)
    if @picture.save
      redirect_to @picture
    else
      render "new"
    end
  end

  def update
    if @picture.update(strong_params)
      redirect_to @picture
    else
      render action: "edit"
    end
  end

  def destroy
    @picture.destroy
    redirect_to @picture.person
  end

  private

  def find_picture
    @picture = Picture.find(params[:id])
  end

  def strong_params
    params.require(:picture).permit(:description, :image, :person_id)
  end
end
