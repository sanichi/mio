class ReturnsController < ApplicationController
  authorize_resource
  before_action :find_returnable, only: [:new]
  before_action :find_return, only: [:edit, :update, :destroy]

  def new
    @return = @returnable.returns.new
  end

  def create
    @return = Return.new(strong_params(true))
    if @return.save
      redirect_to @return.returnable
    else
      @returnable = @return.returnable
      render "new"
    end
  end

  def update
    if @return.update(strong_params)
      redirect_to @return.returnable
    else
      render "edit"
    end
  end

  def destroy
    @return.destroy
    redirect_to @return.returnable
  end

  private

  def find_returnable
    klass = [Fund].detect{ |c| params["#{c.name.underscore}_id"] }
    @returnable = klass.find(params["#{klass.name.underscore}_id"])
  end

  def find_return
    @return = Return.find(params[:id])
    @returnable = @return.returnable
  end

  def strong_params(new_record=false)
    list = %i{year percent}
    list.concat %i{returnable_type returnable_id} if new_record
    params.require(:return).permit(*list)
  end
end
