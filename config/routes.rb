Rails.application.routes.draw do
  root to: "masses#graph"

  get "sign_in"  => "sessions#new"
  get "sign_out" => "sessions#destroy"

  resources :expenses, except: [:show]
  resources :funds do
    resources :comments, except: [:index, :show]
    resources :returns, except: [:index, :show]
  end
  resources :incomes, except: [:show] { get :graph, on: :collection }
  resources :masses, except: [:show] { get :graph, on: :collection }
  resources :sessions, only: [:create]
  resources :transactions, only: [:index, :show] { get :summary, on: :collection }
  resources :uploads, except: [:edit, :update]
end
