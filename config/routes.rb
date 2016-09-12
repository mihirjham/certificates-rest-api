Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :customers, only: [:create, :destroy] do
        resources :certificates, only: [:create] do
          get :active, on: :collection
        end
      end

      resources :certificates, only: [] do
        put :activate, on: :collection
        put :deactivate, on: :collection
      end
    end
  end
end
