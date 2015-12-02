class BlogsController < ApplicationController
  authorize_resource
  before_action :find_blog, only: [:show, :edit, :update, :destroy]

  def index
    @blogs = Blog.search(params, current_user)
  end

  def new
    @blog = Blog.new
  end

  def create
    @blog = Blog.new(strong_params(add_user: true))
    if @blog.save
      redirect_to @blog
    else
      render "new"
    end
  end

  def update
    if @blog.update(strong_params)
      redirect_to @blog
    else
      render action: "edit"
    end
  end

  def destroy
    @blog.destroy
    redirect_to blogs_path
  end

  private

  def find_blog
    @blog = Blog.find(params[:id])
  end

  def strong_params(add_user: false)
    allowed = [:draft, :story, :title]
    if add_user
      params[:blog][:user_id] = session[:user_id]
      allowed.push(:user_id)
    end
    params.require(:blog).permit(*allowed)
  end
end
