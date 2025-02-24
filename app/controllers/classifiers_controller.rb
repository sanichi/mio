class ClassifiersController < ApplicationController
  authorize_resource
  before_action :find_classifier, only: [:show, :edit, :update, :destroy]

  def index
    remember_last_search(classifiers_path)
    @classifiers = Classifier.search(params, classifiers_path, per_page: 10)
  end

  def new
    @classifier = Classifier.new
  end

  def create
    @classifier = Classifier.new(strong_params)
    if @classifier.save
      redirect_to @classifier
    else
      failure @classifier
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @classifier.update(strong_params)
      redirect_to @classifier
    else
      failure @classifier
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @classifier.destroy
    redirect_to classifiers_path
  end

  private

  def find_classifier
    @classifier = Classifier.find(params[:id])
  end

  def strong_params
    params.require(:classifier).permit(:category, :color, :description, :max_amount, :min_amount, :name)
  end
end
