class GrammarGroupsController < ApplicationController
  load_and_authorize_resource

  def index
    @grammar_groups = GrammarGroup.search(@grammar_groups, params, grammar_groups_path)
  end

  def create
    if @grammar_group.save
      redirect_to @grammar_group
    else
      failure @grammar_group
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @grammar_group.update(resource_params)
      redirect_to @grammar_group
    else
      failure @grammar_group
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @grammar_group.destroy
    redirect_to grammar_groups_path
  end

  def show
    @group = @grammar_group
  end

  private

  def resource_params
    params.require(:grammar_group).permit(:title)
  end

  def rename_groups
    @grammar_groups = @grammar_groups
  end
end
