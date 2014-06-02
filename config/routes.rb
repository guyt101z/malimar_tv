Rails.application.routes.draw do
  devise_for :admins
  devise_for :sales_representatives
  devise_for :users
  
  
  
  	# User Methods
  	get 'account' => 'users#account'
  
  
  	# Admin Methods
  	get 'admins' => 'admins#index'
  
  		# Manage Users
  		get '/admins/users' => 'admins#users', as: 'search_users'
  		get 'search_users' => 'admins#search_users'
  		get 'view_user' => 'admins#view_user'
  		post 'add_note_to_user' => 'users#add_note'
  		post 'admin_register_device' => 'admins#register_device'
  		
  		get '/admins/new_user' => 'admins#new_user', as: 'new_user'
  		post 'admin_create_user' => 'admins#create_user'
  
  
  get 'search_suggestions' => 'videos#search_suggestions'
  get 'subscribe' => 'users#subscribe'
  post 'add_subscription' => "users#add_subscription"
  
  post 'create_new_user' => 'users#create_new'
  
  root :to => 'videos#landing'
  
end
