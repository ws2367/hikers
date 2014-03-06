#require 'home_app.rb'

Hikers::Application.routes.draw do

  get "institutions/index"

  post "pictures/:post_id" => 'pictures#create'
  get "pictures/:post_id/:index" => 'pictures#show'

namespace :v1  do
  resources :locations
  resources :institutions
  resources :entities
  resources :posts
  resources :comments
  
  resources :posts do
    resources :comments, only: [:index]
  end
end

  resources :follows
  resources :views
  resources :shares
  resources :hates
  resources :likes

#    match "/sinatra" => HomeApp, :anchor => false

  devise_for :users, :controllers => {sessions:'sessions'} # Custom controller for API token access

  resources :users
  #match 'users/:id' => 'users#show', as: :user
  post 'orderposts' => 'posts#order'

  post 'searchposts' => 'posts#search'

  post 'addnumshares' => 'shares#addnum'

  get 'S3Credentials' => 'credentials#get'

  #root :to => "pins#index"
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end
  
  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
