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

  def show
    if @grammar
      @examples = @grammar.update_examples.reverse
      @next = Grammar.find_by(id: @grammar.id + 1)
      @prev = Grammar.find_by(id: @grammar.id - 1)
    end
  end

  def quick_level_update
    @grammar.update_level!(params[:delta].to_i)
  end

  def remove_example
    @example_id = params[:example_id].to_i
    @grammar.update_column(:examples, @grammar.examples.delete_if{ |e| e == @example_id })
  end

  private

  def resource_params
    params.require(:grammar).permit(:eregexp, :note, :regexp, :title)
  end
end
