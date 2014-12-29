Rails.application.routes.draw do
  root to: "pages#home"
  
  %w[home].each do |page|
    get page => "pages##{page}"
  end

  resources :uploads, except: [:edit, :update]
end
