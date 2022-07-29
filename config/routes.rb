Rails.application.routes.draw do
  root to: "favourites#index"

  get "sign_in"  => "sessions#new"
  get "sign_out" => "sessions#destroy"
  resource :otp_secret, only: [:new, :create]

  %w[aoc board env deeds magic pam play prefectures premier risle ruby weight].each do |page|
    get page => "pages##{page}"
  end

  resources :blogs
  resources :favourites
  resources :flats
  resources :grammars do
    patch :quick_level_update, on: :member
    delete :remove_example, on: :member
  end
  resources :grammar_groups
  resources :lessons
  resources :logins, only: [:index]
  resources :masses, except: [:show]
  resources :matches, only: [:index]
  resources :misas
  resources :notes
  resources :partnerships
  resources :people do
    get :checks, on: :collection
    get :match, on: :collection
    get :relative, on: :member
    get :tree, on: :collection
  end
  resources :pictures
  resources :places do
    get :move, on: :member
    patch :shift, on: :member
  end
  resources :problems
  resources :questions
  resources :sessions, only: [:create]
  resources :sounds, only: [:index, :show, :edit, :update] do
    patch :quick_level_update, on: :member
  end
  resources :teams
  resources :tests, only: [:index, :update] do
    get :review, on: :collection
  end
  resources :tutorials
  resources :users
  namespace :wk do
    resources :examples, except: [:show]
    resources :groups, except: [:show]
    resources :kanjis, only: [:index, :show]
    resources :radicals, only: [:index, :show]
    resources :readings, only: [] do
      patch :quick_accent_update, on: :member
    end
    resources :verb_pairs, only: [:index]
    resources :vocabs, only: [:edit, :index, :show, :update]
  end
end
