class LinksController < ApplicationController
  authorize_resource
  before_action :find_linkable, only: [:new]
  before_action :find_link, only: [:edit, :update, :destroy]

  def new
    @link = @linkable.links.new
  end

  def create
    @link = Link.new(strong_params(true))
    if @link.save
      redirect_to @link.linkable
    else
      @linkable = @link.linkable
      render "new"
    end
  end

  def update
    if @link.update(strong_params)
      redirect_to @link.linkable
    else
      render "edit"
    end
  end

  def destroy
    @link.destroy
    redirect_to @link.linkable
  end

  private

  def find_linkable
    klass = [Fund].detect{ |c| params["#{c.name.underscore}_id"] }
    @linkable = klass.find(params["#{klass.name.underscore}_id"])
  end

  def find_link
    @link = Link.find(params[:id])
    @linkable = @link.linkable
  end

  def strong_params(new_record=false)
    list = %i{url target text}
    list.concat %i{linkable_type linkable_id} if new_record
    params.require(:link).permit(*list)
  end
end
