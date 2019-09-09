Rails.application.routes.draw do
  root to: "blogs#index"

  get "sign_in"  => "sessions#new"
  get "sign_out" => "sessions#destroy"

  %w[aoc check deeds magic pam play risle risle_stats tribute].each do |page|
    get page => "pages##{page}"
  end

  resources :blogs
  resources :books
  resources :buckets
  resources :conversations
  resources :devices
  resources :dragons, except: [:show]
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
  resources :kanjis, only: [:index, :show]
  resources :kanji_questions, only: [:create]
  resources :kanji_tests, only: [:index, :show, :new, :create, :destroy]
  resources :lessons
  resources :logins, only: [:index]
  resources :masses, except: [:show] do
    get :graph, on: :collection
  end
  resources :misas
  resources :notes
  resources :occupations
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
  resources :radicals, only: [:index]
  resources :readings, only: [:index, :show]
  resources :residents
  resources :sessions, only: [:create]
  resources :similar_kanjis
  resources :similar_words
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
  resources :verb_pairs
  resources :vocab_questions, only: [:create]
  resources :vocab_tests, only: [:index, :show, :new, :create, :destroy]
  resources :vocabs do
    get :homonyms, :verbs, on: :collection
    patch :quick_accent_update, on: :member
  end
  namespace :wk do
    resources :vocabs, only: [:index, :show] do
      patch :quick_accent_update, on: :member
    end
    resources :kanjis, only: [:index, :show]
    resources :radicals, only: [:index, :show]
  end
end
