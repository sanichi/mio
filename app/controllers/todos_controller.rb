class TodosController < ApplicationController
  authorize_resource
  before_action :find_todo, only: [:up, :down, :toggle, :edit, :update, :destroy]

  def index
    @todos = Todo.ordered
  end

  def new
    @todo = Todo.new
  end

  def create
    @todo = Todo.new(strong_params)
    if @todo.save
      redirect_to(todos_path)
    else
      render(action: "new")
    end
  end

  def update
    if @todo.update(strong_params)
      redirect_to(todos_path)
    else
      render(action: "edit")
    end
  end

  def toggle
    @todo.update_column(:done, !@todo.done)
    redirect_to(todos_path)
  end

  def up
    @todo.update_column(:priority, @todo.priority - 1) unless @todo.highest_priority?
    redirect_to(todos_path)
  end

  def down
    @todo.update_column(:priority, @todo.priority + 1) unless @todo.lowest_priority?
    redirect_to(todos_path)
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
