class PicturesController < ApplicationController
  authorize_resource
  before_action :find_picture, only: [:show, :edit, :update, :destroy]

  def index
    @pictures = Picture.search(params)
    prev_next(:picture_ids, @pictures)
  end

  def new
    person_id = params[:person_id].to_i
    person = Person.find_by(id: person_id) if person_id > 0
    people = [person].compact
    @picture = Picture.new(people: people)
  end

  def create
    @picture = Picture.new(strong_params)
    update_people
    if @picture.save
      redirect_to @picture
    else
      render "new"
    end
  end

  def update
    update_people
    if @picture.update(strong_params)
      redirect_to @picture
    else
      render action: "edit"
    end
  end

  def destroy
    @picture.destroy
    redirect_to pictures_path
  end

  private

  def find_picture
    @picture = Picture.includes(:people).find(params[:id])
  end

  def strong_params
    params.require(:picture).permit(:description, :image, :portrait)
  end

  def update_people
    @picture.update_people(params[:picture][:people])
  end
end
