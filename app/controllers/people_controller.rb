class PeopleController < ApplicationController
  authorize_resource
  before_action :find_person, only: [:destroy, :edit, :show, :update]

  def index
    @people = Person.search(params, people_path, remote: true)
  end

  def new
    @person = Person.new
  end

  def show
    prev_next(:picture_ids, @person.pictures)
  end

  def create
    @person = Person.new(strong_params)
    if @person.save
      redirect_to @person
    else
      render "new"
    end
  end

  def update
    if @person.update(strong_params)
      redirect_to @person
    else
      render "edit"
    end
  end

  def destroy
    @person.destroy
    redirect_to people_path
  end

  private

  def find_person
    @person = Person.find(params[:id])
  end

  def strong_params
    params.require(:person).permit(:born, :died, :first_names, :gender, :known_as, :last_name, :notes)
  end
end
