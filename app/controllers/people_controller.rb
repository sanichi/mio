class PeopleController < ApplicationController
  authorize_resource
  before_action :find_person, only: [:destroy, :edit, :show, :update]

  def index
    @people = Person.search(params, people_path, remote: true)
  end

  def match
    @people = Person.match(params)
    respond_to do |format|
      format.json { render json: @people }
    end
  end

  def tree
    @person = Person.find_by(id: params[:id]) || current_user.person || Person.offset(rand(Person.count)).first
    respond_to do |format|
      format.html
      format.json { render json: @person.tree_hash(true) }
    end
  end

  def relative
    p = Person.find_by(id: params[:id])
    o = Person.find_by(id: params[:other])
    relationship = p && o ? p.relationship(o).to_s(caps: true) : I18n.t("error")
    respond_to do |format|
      format.json { render text: relationship }
    end
  end

  def checks
    @checks = PeopleChecks.new
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
    params.require(:person).permit(:born, :born_guess, :died, :died_guess, :father_id, :first_names, :known_as, :last_name, :male, :married_name, :mother_id, :notes, :realm)
  end
end
