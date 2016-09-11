Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :customers, only: [:create, :destroy]
    end
  end
end
