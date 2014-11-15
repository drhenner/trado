Trado::Application.routes.draw do

  root to: 'store#home'

  # Custom routes
  get '/carts/delivery_service_prices/update' => 'delivery_service_prices#update'
  get '/product/skus' => 'skus#update'
  get '/product/accessories' => 'accessories#update'
  get '/search' => 'search#results'
  get '/search/autocomplete' => 'search#autocomplete'

  # Error pages
  %w( 404 422 500 ).each do |code|
    get code, to: "errors#show", code: code
  end

  # Pages system
  namespace :p do
    get ':slug', to: 'pages#show'
    resources :pages, only: [] do
      post 'send_contact_message', on: :collection
    end
  end

  devise_for :users, controllers: { registrations: "users/registrations", sessions: "users/sessions" }
  resources :users
  resources :contacts, only: :create
  resources :delivery_service_prices, only: :update
  

  resources :categories, only: :show do
    resources :products, only: :show do
      resources :skus, only: [] do
        get 'notify', on: :member
        resources :notifications, only: :create
      end
    end
  end
  
  resources :carts, only: [] do
    collection do
      get 'mycart'
      get 'checkout'
      patch 'estimate'
      delete 'purge_estimate'
    end
    post 'confirm', on: :collection
    resources :cart_items, only: [:create, :update, :destroy] do
      resources :cart_item_accessories, only: [:update, :destroy]
    end
  end

  resources :orders, only: [:destroy] do
    member do
      get 'success'
      get 'failed'
      get 'retry'
      get 'confirm'
      post 'complete'
    end
    resources :addresses, only: [:new, :create, :update]
  end

  namespace :admin do
      root to: "admin#dashboard"
      post '/paypal/ipn' => 'transactions#paypal_ipn'
      mount RedactorRails::Engine => '/redactor_rails'
      resources :accessories, :categories, except: :show
      resources :products, except: [:show, :create] do
        resources :attachments, except: [:index, :show]
        resources :skus, except: [:index, :show] do
          resources :stock_levels, only: [:create, :new]
        end
      end
      resources :orders, only: [:index, :show, :update, :edit] do
        resources :transactions, only: [:edit, :update]
      end
      resources :delivery_services, except: :show do
        collection do
          get 'copy_countries'
          post 'set_countries'
        end
        resources :delivery_service_prices, path: 'prices', except: :show
      end
      
      namespace :products do
        resources :tags, only: :index
      end
      resources :pages, except: [:show, :destroy, :new, :create]
      get '/settings' => 'admin#settings'
      patch '/settings/update' => 'admin#update'
      get '/profile' => 'users#edit'
      patch '/profile/update' => 'users#update'
  end

  # # redirect unknown URLs to 404 error page
  # match '*path', via: :all, to: 'errors#show', code: 404

end
