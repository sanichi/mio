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
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @grammar.update(resource_params)
      redirect_to @grammar
    else
      failure @grammar
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @grammar.destroy
    redirect_to grammars_path
  end

  def show
    if @grammar
      @examples = @grammar.update_examples.reverse
      ids = Grammar.by_ref.pluck(:id)
      ind = ids.index(@grammar.id)
      @next = Grammar.find_by(id: ids[ind + 1]) || Grammar.find_by(id: ids[0])
      @prev = Grammar.find_by(id: ids[ind - 1]) || Grammar.find_by(id: ids[-1])
      @groups = @grammar.groups.by_title
      @others = GrammarGroup.by_title.all - @groups
    end
  end

  def quick_level_update
    @grammar.update_level!
  end

  def remove_example
    @example = Wk::Example.find(params[:example_id])
    @grammar.update_column(:examples, @grammar.examples.delete_if{ |e| e == @example.id })
  end

  def add_group
    group = GrammarGroup.find_by(id: params[:group_id])
    @grammar.groups << group if group
    redirect_to @grammar
  end

  def remove_group
    group = GrammarGroup.find_by(id: params[:group_id])
    @grammar.groups.delete(group) if group
    redirect_to @grammar
  end

  private

  def resource_params
    params.require(:grammar).permit(:eregexp, :jregexp, :note, :ref, :title)
  end
end
