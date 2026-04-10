Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      post "register", to: "authentication#register"
      post "login", to: "authentication#login"
    end
  end
end
