class HistoricalEventsController < ApplicationController
  authorize_resource
  before_action :find_event, only: [:edit, :update, :destroy]

  def index
    @events = HistoricalEvent.by_year.all
  end

  def new
    @event = HistoricalEvent.new
  end

  def create
    @event = HistoricalEvent.new(strong_params)
    if @event.save
      redirect_to historical_events_path
    else
      render "new"
    end
  end

  def update
    if @event.update(strong_params)
      redirect_to historical_events_path
    else
      render "edit"
    end
  end

  def destroy
    @event.destroy
    redirect_to historical_events_path
  end

  private

  def find_event
    @event = HistoricalEvent.find(params[:id])
  end

  def strong_params
    params.require(:historical_event).permit(:description, :finish, :start)
  end
end
