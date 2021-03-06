Moose::Application.routes.draw do

namespace :v1  do
  resources :comments, only: [:create]

  resources :posts , only: [:index, :create] do
    resources :comments, only: [:index]
  end

  resources :entities, only: [] do
    resources :posts, only: [:index]
  end

  get 'S3Credentials' => 'credentials#create'

  post 'posts/:post_id/follow' => 'posts#follow'
  delete 'posts/:post_id/unfollow' => 'posts#unfollow'

  post 'posts/:post_id/report' => 'posts#report'
  post 'posts/:post_id/share' => 'posts#share'
  post 'posts/:post_id/activate' => 'posts#activate'

  # Custom controller for API token access
  devise_for :users, only: :sessions, :controllers => {sessions:'v1/sessions'} 

  post 'users/set_badge' => 'users#set_badge'
  post 'users/set_device_token' => 'users#set_device_token'

  get 'letters/check' => 'letters#check'
end

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
