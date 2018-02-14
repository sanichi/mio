class NotesController < ApplicationController
  authorize_resource
  before_action :find_note, only: [:show, :edit, :update, :destroy]

  def index
    @notes = Note.search(params, notes_path)
  end

  def new
    @note = Note.new
  end

  def create
    @note = Note.new(strong_params)
    if @note.save
      redirect_to @note
    else
      render "new"
    end
  end

  def update
    if @note.update(strong_params)
      redirect_to @note
    else
      render action: "edit"
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
    params.require(:note).permit(:stuff, :title)
  end
end
