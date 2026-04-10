Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      post   "register", to: "authentication#register"
      post   "login",    to: "authentication#login"
      delete "logout",   to: "authentication#logout"

      resources :books, only: [:index, :show, :create, :update, :destroy]

      resources :borrowings, only: [:index, :create] do
        member do
          patch :return
        end
      end

      get "dashboard", to: "dashboard#index"
    end
  end
end
