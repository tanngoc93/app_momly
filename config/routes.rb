Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    omniauth_callbacks: 'users/omniauth_callbacks'
  }

  # Route reset API token cho user
  namespace :users do
    resource :api_token, only: [] do
      post :reset
    end
  end

  # Health check (important for Docker, uptime monitoring, etc.)
  get "/health", to: proc { [200, { "Content-Type" => "text/plain" }, ["OK"]] }

  # Root path (homepage with form to create short links)
  root "home#index"

  # Short link management (HTML form + Turbo Stream support)
  resources :short_links, only: [:create, :destroy] do
    member do
      get :stats
    end
  end

  # Public listing of recent short links
  get "/public_links", to: "public_links#index", as: :public_links

  #
  get "/my_links_modal", to: "short_links#modal", as: :my_links_modal

  # API namespace for versioned endpoints
  namespace :api do
    namespace :v1 do
      # POST /api/v1/short_links
      resources :short_links, only: [:create, :index, :show, :update, :destroy] do
        get :stats, on: :member
      end
    end
  end

  # Dynamic short link redirection
  # Must be placed at the bottom to avoid route collision
  get "/:short_code", to: "short_links#redirect", as: :redirect_short
end
