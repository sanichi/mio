class UsersController < ApplicationController
  authorize_resource
  before_action :find_user, only: [:destroy, :edit, :show, :update]

  def index
    @users = User.search(params, users_path, remote: true)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(strong_params)
    if @user.save
      redirect_to @user
    else
      render "new"
    end
  end

  def update
    if @user.update(strong_params)
      redirect_to @user
    else
      render "edit"
    end
  end

  def destroy
    @user.destroy
    redirect_to users_path
  end

  private

  def find_user
    @user = User.find(params[:id])
  end

  def strong_params
    params.require(:user).permit(:email, :password, :role)
  end
end
