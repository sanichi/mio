class SessionsController < ApplicationController
  def create
    user = User.find_by(email: params[:email], encrypted_password: Digest::MD5.hexdigest(params[:password]))
    if user
      session[:user_id] = user.id
      redirect_to root_path
    else
      render "new"
    end
  end

  def destroy
    session.delete(:user_id)
    render "new"
  end
end
