require 'sidekiq/web'

Trado::Application.routes.draw do
  mount TradoGooglemerchantModule::Engine => '/google_merchant'


  root to: 'store#home'
  # Custom routes
  get '/baskets/delivery_service_prices/update' => 'delivery_service_prices#update'
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
  
  resources :carts, only: [], path: 'baskets' do
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
      # authenticate :user, lambda { |u| u.role?(:admin) } do
        mount Sidekiq::Web => '/sidekiq'
      # end
      resources :accessories, :categories, except: :show
      resources :news_items, path: 'news', except: :show
      resources :products, except: [:show, :create] do
        resources :attachments, except: :index
        resources :skus, except: [:index, :show] do
          resources :stock_adjustments, only: [:create, :new]
        end
        namespace :skus do
          resources :sku_variants, as: 'variants', path: 'variants', controller: :variants, only: [:new, :create] do
            collection do
              patch 'update', as: 'update'
              delete 'destroy', as: 'destroy'
            end
          end
        end
      end
      resources :orders, only: [:index, :show, :update, :edit] do
        member do
          get :dispatcher
          post :dispatched
          get :receipt
        end
      end
      resources :transactions, only: [:edit, :update]
      resources :delivery_services, except: :show do
        collection do
          get 'copy_countries'
          post 'set_countries'
        end
        resources :delivery_service_prices, path: 'prices', except: :show
      end
      
      namespace :products do
        resources :tags, only: :index
        resources :stock, only: [:index, :show]
      end
      resources :pages, except: [:show, :destroy, :new, :create]
      get '/settings' => 'admin#settings'
      patch '/settings/update' => 'admin#update'
      get '/profile' => 'users#edit'
      patch '/profile/update' => 'users#update'
  end

  namespace :api, constraints: { format: 'json' } do
    resources :attachments, only: [] do
      collection do
        post :delete_s3_froala_upload
        get :s3_froala_uploads
      end
    end
  end

  # # redirect unknown URLs to 404 error page
  # match '*path', via: :all, to: 'errors#show', code: 404

end
