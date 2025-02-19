class PeopleController < ApplicationController
  authorize_resource
  before_action :find_person, only: [:destroy, :edit, :show, :update]

  def index
    params[:realm] = current_realm
    remember_last_search(people_path)
    @people = Person.search(params, people_path)
  end

  def match
    params[:realm] = current_realm
    @people = Person.match(params)
    respond_to do |format|
      format.json { render json: @people }
    end
  end

  def tree
    @person = Person.find_by(id: params[:id]) || Person.where(realm: current_realm, default: true).to_a.sample || Person.where(realm: current_realm).order(updated_at: :desc).first
    respond_to do |format|
      format.html
      format.json { render json: @person.tree_hash(true) }
    end
  end

  def relative
    p = Person.find_by(id: params[:id])
    o = Person.find_by(id: params[:other])
    relationship = p && o ? p.relationship(o).to_s(caps: true) : I18n.t("error")
    render plain: relationship
  end

  def checks
    @checks = PeopleChecks.new
  end

  def new
    @person = Person.new(realm: current_realm)
  end

  def show
    prev_next(:picture_ids, @person.pictures)
  end

  def create
    params[:person][:realm] = current_realm
    @person = Person.new(strong_params)
    if @person.save
      redirect_to @person
    else
      failure @person
      render :new
    end
  end

  def update
    params[:person][:realm] = current_realm
    if @person.update(strong_params)
      redirect_to @person
    else
      failure @person
      render :edit
    end
  end

  def destroy
    @person.destroy
    redirect_to people_path
  end

  def set_realm
    if params[:realm]
      realm = params[:realm].to_i
      if realm >= Person::MIN_REALM && realm <= Person::MAX_REALM
        session[:current_realm] = realm
      end
    end
    redirect_to people_path
  end

  private

  def find_person
    @person = Person.find(params[:id])
  end

  def strong_params
    params.require(:person).permit(:born, :born_guess, :default, :died, :died_guess, :father_id, :first_names, :known_as, :last_name, :male, :married_name, :mother_id, :notes, :realm, :sensitive)
  end
end
