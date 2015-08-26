Rails.application.routes.draw do
  root to: "masses#graph"

  get "sign_in"  => "sessions#new"
  get "sign_out" => "sessions#destroy"

  %w[pills].each do |page|
    get page => "pages##{page}"
  end

  resources :expenses, except: [:show]
  resources :funds do
    resources :comments, except: [:index, :show]
    resources :links, except: [:index, :show]
    resources :returns, except: [:index, :show]
  end
  resources :incomes, except: [:show] do
    get :graph, on: :collection
  end
  resources :logins, only: [:index]
  resources :masses, except: [:show] do
    get :graph, on: :collection
  end
  resources :partnerships
  resources :people do
    get :match, on: :collection
    get :relative, on: :member
  end
  resources :pictures
  resources :sessions, only: [:create]
  resources :transactions, only: [:index, :show] { get :summary, on: :collection }
  resources :todos, except: [:show] do
    get :toggle, on: :member
    get :elm, on: :collection
  end
  resources :uploads, except: [:edit, :update]
  resources :users
end
