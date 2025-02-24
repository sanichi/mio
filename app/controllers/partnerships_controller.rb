class PartnershipsController < ApplicationController
  authorize_resource
  before_action :find_partnership, only: [:destroy, :edit, :show, :update]

  def index
    remember_last_search(partnerships_path)
    @partnerships = Partnership.search(params, partnerships_path)
  end

  def new
    person_id = params[:person_id].to_i
    if person_id > 0 && (person = Person.find_by(id: person_id))
      if person.male
        husband_id = person_id
      else
        wife_id = person_id
      end
    end
    @partnership = Partnership.new(husband_id: husband_id, wife_id: wife_id, realm: current_realm)
  end

  def create
    params[:partnership][:realm] = current_realm
    @partnership = Partnership.new(strong_params)
    if @partnership.save
      redirect_to @partnership
    else
      failure @partnership
      render :new, status: :unprocessable_entity
    end
  end

  def update
    params[:partnership][:realm] = current_realm
    if @partnership.update(strong_params)
      redirect_to @partnership
    else
      failure @partnership
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @partnership.destroy
    redirect_to partnerships_path
  end

  private

  def find_partnership
    @partnership = Partnership.find(params[:id])
  end

  def strong_params
    params.require(:partnership).permit(:divorce, :divorce_guess, :husband_id, :marriage, :realm, :wedding, :wedding_guess, :wife_id)
  end
end
