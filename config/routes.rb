Rails.application.routes.draw do
  root to: "transactions#index"

  resources :uploads, except: [:edit, :update]
  resources :transactions, only: [:index, :show]
end
