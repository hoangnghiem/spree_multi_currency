Spree::Core::Engine.add_routes do
  post '/currency/set', to: 'currency#set', defaults: { format: :json }, as: :set_currency

  namespace :admin do
    resources :products do
      resources :prices, only: [:index, :create] do
        post :apply, on: :collection
      end
    end
    resources :currencies do
      post :apply_all, on: :collection
      post :apply, on: :member
    end
  end
end
