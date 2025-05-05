Rails.application.routes.draw do
  # 🔐 User authentication
  devise_for :users

  # ✅ Healthcheck route (should be defined before dynamic routes)
  get "/health", to: proc { [200, { "Content-Type" => "text/plain" }, ["OK"]] }

  # 🌐 Short link creation (HTML form and Turbo response)
  resources :short_links, only: [:create]

  # 📦 API namespace for versioned endpoints
  namespace :api do
    namespace :v1 do
      resources :short_links, only: [:create]
    end
  end

  # 🔁 Redirection handler for short codes
  # Make sure this is below specific paths like /health
  get "/:short_code", to: "short_links#redirect", as: :redirect_short

  # 🏠 Root path for the homepage
  root "short_links#home"
end
