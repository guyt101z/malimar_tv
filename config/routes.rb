Rails.application.routes.draw do
  devise_for :admins
  devise_for :sales_representatives
  devise_for :users
  
  
    # Roku API
    get '/api/authenticate' => 'api#authenticate' 

  	# User Methods
    authenticate :user do
  	  	get 'account' => 'users#account'

        get '/account/new_ticket' => 'users#new_ticket', as: 'user_new_ticket'
        post 'user_create_ticket' => 'support#user_create_ticket'
        get 'user_view_ticket' => 'support#user_view_ticket'
        post 'user_send_message_on_ticket' => 'support#user_send_message'
        post 'user_attach_file_to_ticket' => 'support#user_attach_file'
    end
  
    get 'events/admin/:id' => 'events#admin_events'
    get 'events/sales_rep/:id' => 'events#sales_rep_events'
    get 'events/user/:id' => 'events#user_events'

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

      get 'accept_payment' => 'transactions#accept'
      get 'cancel_payment' => 'transactions#cancel'
      get 'refund_payment' => 'transactions#refund'
  	
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
      	get '/admins/financial' => 'admins#plans'
      	post 'update_plan' => 'plans#update'
        post 'update_paypal' => 'admins#update_paypal'

        # Activity Feed
        get 'load_activity_feed' => 'feed#load'
        get 'load_admin_activity_feed' => 'feed#load_admin'
        get 'refresh_feed' => 'feed#refresh'
        get '/admins/view_update' => 'feed#view_update', as: 'view_update'

        # Support
        get '/admins/support' => 'admins#support', as: 'admin_support'
        get '/admins/support/new' => 'admins#new_tickets', as: 'admin_new_tickets'
        get '/admins/support/archived' => 'admins#archived_tickets', as: 'admin_archived_tickets'

        get 'admin_view_ticket' => 'support#admin_view_ticket'
        get 'accept_ticket' => 'support#accept_ticket'
        get 'close_ticket' => 'support#close_ticket'
        get 'reopen_ticket' => 'support#reopen_ticket'

        post 'admin_send_message_on_ticket' => 'support#admin_send_message'
        post 'admin_attach_file_to_ticket' => 'support#admin_attach_file'

        get 'issue_refund' => 'support#issue_refund'
    end

    authenticate :sales_representative do
    	get 'sales_reps' => 'sales_reps#index'

    	get '/sales_reps/register' => 'sales_reps#register'
    	post 'register_step_one' => 'sales_reps#register_step_one'
    	get 'sales_rep_choose_plan' => 'sales_reps#choose_plan'
    	post 'sales_rep_add_subscription' => 'sales_reps#add_subscription'

    	get '/sales_reps/transactions' => 'sales_reps#transactions'

    	get '/sales_reps/settings' => 'sales_reps#settings'

      get '/sales_reps/support' => 'sales_reps#support', as: 'sales_rep_support'
      get '/sales_reps/archived_tickets' => 'sales_reps#archived_tickets', as: 'sales_rep_archived_tickets'
      get '/sales_reps/new_ticket' => 'sales_reps#new_ticket', as: 'sales_rep_new_ticket'
      post 'sales_rep_create_ticket' => 'support#sales_rep_create_ticket'
      get 'sales_rep_view_ticket' => 'support#sales_rep_view_ticket'

      post 'sales_rep_send_message_on_ticket' => 'support#sales_rep_send_message'
      post 'sales_rep_attach_file_to_ticket' => 'support#sales_rep_attach_file'
    end
  
  get 'view_invoice/:id' => 'transactions#view_invoice', as: 'view_invoice'
  get 'view_user_invoice/:id' => 'transactions#view_all', as: 'view_user_invoice'

  get 'search_suggestions' => 'videos#search_suggestions'
  get 'subscribe' => 'users#subscribe'
  post 'add_subscription' => "users#add_subscription"
  
  post 'create_new_user' => 'users#create_new'
    	get 'rep_commission' => 'sales_reps#rep_commission'
    	get 'rep_commission_owed' => 'sales_reps#rep_commission_owed'
    	get 'rep_commission_paid' => 'sales_reps#rep_commission_paid'
  
  root :to => 'videos#landing'
  
end
