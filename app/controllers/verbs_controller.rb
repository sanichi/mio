class VerbsController < ApplicationController
  authorize_resource
  before_action :find_verb, only: [:destroy, :edit, :show, :update]

  def index
    @verbs = Verb.search(params, verbs_path, remote: true, per_page: 20)
  end

  def new
    @verb = Verb.new
  end

  def create
    @verb = Verb.new(strong_params)
    if @verb.save
      redirect_to @verb
    else
      render action: "new"
    end
  end

  def update
    if @verb.update(strong_params)
      redirect_to @verb
    else
      render action: "edit"
    end
  end

  def destroy
    @verb.destroy
    redirect_to verbs_path
  end

  private

  def find_verb
    @verb = Verb.find(params[:id])
  end

  def strong_params
    params.require(:verb).permit(:category, :kanji, :meaning, :reading, :transitive)
  end
end
