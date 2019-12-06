Rails.application.routes.draw do
  root to: "favourites#index"

  get "sign_in"  => "sessions#new"
  get "sign_out" => "sessions#destroy"

  %w[aoc check deeds magic pam play risle risle_stats].each do |page|
    get page => "pages##{page}"
  end

  resources :blogs
  resources :books, only: [:show, :index]
  resources :buckets
  resources :devices
  resources :expenses, except: [:show]
  resources :favourites
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
  resources :lessons
  resources :logins, only: [:index]
  resources :masses, except: [:show] do
    get :graph, on: :collection
  end
  resources :misas
  resources :notes
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
  resources :problems
  resources :questions
  resources :residents
  resources :sessions, only: [:create]
  resources :tapas, except: [:show] do
    get :notes, on: :member
  end
  resources :todos, except: [:show] do
    get :toggle, on: :member
    get :up, on: :member
    get :down, on: :member
  end
  resources :transactions, only: [:index, :show] do
    get :summary, on: :collection
  end
  resources :trades
  resources :uploads, except: [:edit, :update]
  resources :users
  resources :vehicles do
    get :match, on: :collection
  end
  namespace :wk do
    resources :examples, except: [:show]
    resources :groups, except: [:show]
    resources :kanjis, only: [:index, :show]
    resources :radicals, only: [:index, :show]
    resources :readings, only: [] do
      patch :quick_accent_update, on: :member
    end
    resources :verb_pairs, only: [:index]
    resources :vocabs, only: [:edit, :index, :show, :update] do
      patch :quick_accent_update, on: :member
    end
  end
end
