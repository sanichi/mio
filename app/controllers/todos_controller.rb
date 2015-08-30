class TodosController < ApplicationController
  authorize_resource
  before_action :find_todo, only: [:toggle, :edit, :update, :destroy]

  def index
    @todos = Todo.ordered
    respond_to do |format|
      format.html
      format.json { render json: @todos.map(&:to_json) }
    end
  end

  def new
    @todo = Todo.new
  end

  def create
    @todo = Todo.new(strong_params)
    if @todo.save
      redirect_to todos_path
    else
      render "new"
    end
  end

  def update
    if @todo.update(strong_params)
      redirect_to todos_path
    else
      render action: "edit"
    end
  end

  def toggle
    @todo.update_column(:done, !@todo.done)
  end

  def destroy
    @todo.destroy
    redirect_to todos_path
  end

  private

  def find_todo
    @todo = Todo.find(params[:id])
  end

  def strong_params
    params.require(:todo).permit(:description, :priority, :done)
  end
end
