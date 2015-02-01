Rails.application.routes.draw do
  root to: "masses#graph"

  get  "sign_in"  => "sessions#new"
  get  "sign_out" => "sessions#destroy"

  resources :sessions, only: [:create]
  resources :transactions, only: [:index, :show]
  resources :uploads, except: [:edit, :update]

  resources :masses, except: [:show] { get :graph, on: :collection }
end
