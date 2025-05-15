Rails.application.routes.draw do
  root to: "favourites#index"

  get "sign_in"  => "sessions#new"
  get "sign_out" => "sessions#destroy"
  resource :otp_secret, only: [:new, :create]

  %w[aoc board env deeds magic pam play prefectures premier risle ruby weight].each do |page|
    get page => "pages##{page}"
  end

  namespace :ks do
    resources :journals, only: [:index, :show]
    resources :boots, only: [:index]
    resources :mems, only: [:index]
    resources :procs, only: [:index]
    resources :pcpus, only: [:index]
  end
  namespace :wk do
    resources :examples, except: [:show] do
      get :memorable, on: :collection
    end
    resources :groups, except: [:show]
    resources :kanas, only: [:edit, :index, :show, :update] do
      patch :quick_accent_update, on: :member
    end
    resources :kanjis, only: [:index, :show] do
      get :similar, on: :collection
    end
    resources :radicals, only: [:index, :show]
    resources :readings, only: [] do
      patch :quick_accent_update, on: :member
    end
    resources :verb_pairs, only: [:index]
    resources :vocabs, only: [:edit, :index, :show, :update]
  end

  resources :blogs
  resources :classifiers
  resources :constellations
  resources :favourites
  resources :flats
  resources :grammars do
    patch :quick_level_update, on: :member
    delete :remove_example, on: :member
    patch :add_group, on: :member
    patch :remove_group, on: :member
  end
  resources :grammar_groups
  resources :logins, only: [:index]
  resources :masses, except: [:show]
  resources :matches, only: [:index]
  resources :misas
  resources :notes
  resources :partnerships
  resources :people do
    get :checks, on: :collection
    get :match, on: :collection
    get :relationship, on: :member
    get :tree, on: :collection
    get :realm, on: :collection
    post :set_realm, on: :collection
  end
  resources :pictures
  resources :places do
    get :move, on: :member
    patch :shift, on: :member
  end
  resources :sessions, only: [:create]
  resources :sounds, only: [:index, :show, :edit, :update] do
    patch :quick_level_update, on: :member
  end
  resources :stars
  resources :teams do
    get :stats, on: :member
  end
  resources :transactions, only: [:index] do
    post :upload, on: :collection
    patch :quick_approval_update, on: :member
  end
  resources :tutorials
  resources :users
end
