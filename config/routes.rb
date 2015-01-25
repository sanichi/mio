Rails.application.routes.draw do
  root to: "transactions#index"

  get  "sign_in"  => "sessions#new"
  get  "sign_out" => "sessions#destroy"

  resources :sessions, only: [:create]
  resources :transactions, only: [:index, :show]
  resources :uploads, except: [:edit, :update]
end
