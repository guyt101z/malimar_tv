Rails.application.routes.draw do
  devise_for :admins
  devise_for :sales_representatives
  devise_for :users
  
  
  
  	# User Methods
    authenticate :user do
  	  	get 'account' => 'users#account'
    end
  
  	# Admin Methods
    authenticate :admin do
  	  	get '/admins' => 'admins#index', as: 'admins'
  
  		# Manage Users
  		get '/admins/users' => 'admins#users', as: 'search_users'
  		get 'search_users' => 'admins#search_users'
  		get 'view_user' => 'admins#view_user'
  		post 'add_note_to_user' => 'users#add_note'
  		post 'admin_register_device' => 'admins#register_device'
  		
  		get '/admins/new_user' => 'admins#new_user', as: 'new_user'
  		post 'admin_create_user' => 'admins#create_user'
  	
  		# Video CMS
  		get '/admins/videos' => 'admins#videos', as: 'videos'
  		post 'add_video' => 'admins#add_video'
  		post 'add_image_to_video' => 'admins#add_image_to_video'

      	# Manage Sales Reps
      	get '/admins/sales_reps' => 'admins#sales_reps'
      	get 'search_reps' => 'admins#search_reps'
      	get 'view_rep' => 'admins#view_rep'
      	get '/admins/new_sales_rep' => 'admins#new_sales_rep'
      	post 'admin_create_sales_rep' => 'admins#create_sales_rep'

      	# Manage Plans
      	get '/admins/plans' => 'admins#plans'
      	post 'update_plan' => 'plans#update'
    end

    authenticate :sales_representative do
    	get 'sales_reps' => 'sales_reps#index'
    	get 'rep_commission' => 'sales_reps#rep_commission'
    	get 'rep_commission_owed' => 'sales_reps#rep_commission_owed'
    	get 'rep_commission_paid' => 'sales_reps#rep_commission_paid'

    	get '/sales_reps/register' => 'sales_reps#register'
    	post 'register_step_one' => 'sales_reps#register_step_one'
    	get 'sales_rep_choose_plan' => 'sales_reps#choose_plan'
    	post 'sales_rep_add_subscription' => 'sales_reps#add_subscription'

    	get '/sales_reps/transactions' => 'sales_reps#transactions'

    	get '/sales_reps/settings' => 'sales_reps#settings'
    end
  
  get 'search_suggestions' => 'videos#search_suggestions'
  get 'subscribe' => 'users#subscribe'
  post 'add_subscription' => "users#add_subscription"
  
  post 'create_new_user' => 'users#create_new'
  
  root :to => 'videos#landing'
  
end
