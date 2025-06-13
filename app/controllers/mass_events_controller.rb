class MassEventsController < ApplicationController
  authorize_resource
  before_action :find_mass_event, only: [:edit, :update, :destroy]

  def index
    @events = MassEvent.search(params, mass_events_path)
  end

  def new
    @event = MassEvent.new
  end

  def create
    @event = MassEvent.new(strong_params)
    if @event.save
      redirect_to mass_events_path
    else
      failure @event
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @event.update(strong_params)
      redirect_to mass_events_path
    else
      failure @event
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event.destroy
    redirect_to mass_events_path
  end

  private

  def find_mass_event
    @event = MassEvent.find(params[:id])
  end

  def strong_params
    params.require(:mass_event).permit(:name, :start, :finish)
  end
end
