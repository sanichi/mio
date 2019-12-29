class LessonsController < ApplicationController
  authorize_resource
  before_action :find_lesson, only: [:show, :edit, :update, :destroy]

  def index
    remember_last_search(lessons_path)
    @lessons = Lesson.search(params, lessons_path, per_page: 20)
  end

  def new
    @lesson = Lesson.new
  end

  def create
    @lesson = Lesson.new(strong_params)
    if @lesson.save
      redirect_to @lesson
    else
      failure @lesson
      render :new
    end
  end

  def update
    if @lesson.update(strong_params)
      redirect_to @lesson
    else
      failure @lesson
      render :edit
    end
  end

  def destroy
    @lesson.destroy
    redirect_to lessons_path
  end

  private

  def find_lesson
    @lesson = Lesson.find(params[:id])
  end

  def strong_params
    params.require(:lesson).permit(:book, :chapter, :chapter_no, :complete, :eco, :link, :note, :section, :series)
  end
end
