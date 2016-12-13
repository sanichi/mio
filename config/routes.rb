Rails.application.routes.draw do
  root to: "blogs#index"

  get "sign_in"  => "sessions#new"
  get "sign_out" => "sessions#destroy"

  %w[aoc check deeds futoshiki play risle risle_stats].each do |page|
    get page => "pages##{page}"
  end

  resources :blogs
  resources :buckets
  resources :devices
  resources :expenses, except: [:show]
  resources :favourites, except: [:show]
  resources :flats
  resources :funds do
    resources :comments, except: [:index, :show]
    resources :links, except: [:index, :show]
    resources :returns, except: [:index, :show]
  end
  resources :historical_events, except: [:show]
  resources :incomes, except: [:show] do
    get :graph, on: :collection
  end
  resources :interfaces
  resources :logins, only: [:index]
  resources :masses, except: [:show] do
    get :graph, on: :collection
  end
  resources :openings do
    get :match, on: :collection
  end
  resources :parkings, only: [:index, :new, :create, :destroy]
  resources :partnerships
  resources :people do
    get :checks, on: :collection
    get :match, on: :collection
    get :relative, on: :member
    get :tree, on: :collection
  end
  resources :pictures
  resources :positions
  resources :residents
  resources :sessions, only: [:create]
  resources :tapas, except: [:show] do
    get :notes, on: :member
  end
  resources :taxes
  resources :todos, except: [:show] do
    get :toggle, on: :member
    get :elm, on: :collection
  end
  resources :transactions, only: [:index, :show] { get :summary, on: :collection }
  resources :trades
  resources :uploads, except: [:edit, :update]
  resources :users
  resources :vehicles do
    get :match, on: :collection
  end
end
