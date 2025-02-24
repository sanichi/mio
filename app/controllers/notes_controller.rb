class NotesController < ApplicationController
  authorize_resource
  before_action :find_note, only: [:show, :edit, :update, :destroy]

  def index
    remember_last_search(notes_path)
    @notes = Note.search(params, notes_path, per_page: 20, locale: :jp)
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
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @note.update(strong_params)
      redirect_to @note
    else
      failure @note
      render :edit, status: :unprocessable_entity
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
end
