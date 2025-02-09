class LoginsController < ApplicationController
  authorize_resource

  def index
    @logins = Login.search(params, logins_path)
  end
end
