class NotesController < ApplicationController
  authorize_resource
  before_action :find_note, only: [:show, :edit, :nedit, :nupdate, :update, :destroy]

  def index
    remember_last_search(notes_path)
    @notes = Note.search(params, notes_path, per_page: 20, locale: :jp)
  end

  def random
    @note = Note.random
  end

  def new
    @note = Note.new
  end

  def create
    @note = Note.new(strong_params)
    if @note.save
      redirect_to @note
    else
      failure @note
      render :new
    end
  end

  def update
    if @note.update(strong_params)
      redirect_to @note
    else
      failure @note
      render :edit
    end
  end

  def nupdate
    msg = @note.shift(nstrong_params)
    if msg
      flash.now[:alert] = msg
      render :nedit
    else
      redirect_to @note
    end
  end

  def destroy
    @note.destroy
    redirect_to notes_path
  end

  private

  def find_note
    @note = Note.find(params[:id])
  end

  def strong_params
    params.require(:note).permit(:number, :series, :stuff, :title)
  end

  def nstrong_params
    params.require(:note).permit(:number)
  end
end
