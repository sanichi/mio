class GrammarsController < ApplicationController
  load_and_authorize_resource

  def index
    @grammars = Grammar.search(@grammars, params, grammars_path)
  end

  def create
    if @grammar.save
      redirect_to @grammar
    else
      failure @grammar
      render :new
    end
  end

  def update
    if @grammar.update(resource_params)
      redirect_to @grammar
    else
      failure @grammar
      render :edit
    end
  end

  def destroy
    @grammar.destroy
    redirect_to grammars_path
  end

  def quick_level_update
    @grammar.update_level!(params[:delta].to_i)
  end

  private

  def resource_params
    params.require(:grammar).permit(:note, :regexp, :title)
  end
end
