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

        get 'view_device/:id' => 'users#view_device', as: 'view_device'
        post 'update_device_serial' => 'users#update_device_serial'
        post 'register_new_device' => 'users#register_new_device'

        post 'update_profile' => 'users#update_profile'
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
        get '/admins/videos/tv_shows' => 'admins#shows', as: 'tv_shows'
        get 'view_show' => 'videos#view_show'

        get '/admins/videos/movies' => 'admins#movies', as: 'movies'
        get 'view_movie' => 'videos#view_movie'

  		get '/admins/videos/live_channels' => 'admins#live_channels', as: 'live_channels'
  		get 'view_channel' => 'videos#view_channel'

        post 'add_show' => 'videos#add_show'
        post 'update_show' => 'videos#update_show'
        post 'update_show_image' => 'videos#update_show_image'

        get 'search_shows' => 'videos#search_shows'
        get 'search_episodes' => 'videos#search_episodes'

        post 'add_episode' => 'videos#add_episode'
        post 'update_episode' => 'videos#update_episode'
        get 'view_episode' => 'videos#view_episode'

        post 'add_channel' => 'videos#add_channel'
        post 'update_channel' => 'videos#update_channel'
        post 'update_channel_image' => 'videos#update_channel_image'

        get 'search_channels' => 'videos#search_channels'

        post 'add_movie' => 'videos#add_movie'
        post 'update_movie' => 'videos#update_movie'
        post 'update_movie_image' => 'videos#update_movie_image'

        get 'search_movies' => 'videos#search_movies'

        get '/admins/videos/home_grid' => 'admins#home_grid'
        post 'add_grid' => 'videos#add_grid'
        post 'update_grid' => 'videos#update_grid'
        get 'delete_grid' => 'videos#delete_grid'
        get 'view_grid' => 'videos#view_grid'

        get 'refresh_grid_view' => 'videos#refresh_grid'

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

        get 'admin_view_device/:id' => 'admins#view_device', as: 'admin_view_device'
        post 'admin_update_device_serial' => 'admins#update_device_serial'
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

    # Roku API
    get '/api/:device' => 'api#home', as: 'api_home' # Home Grid Feed
    get '/api/:device/:channel_id' => 'api#channel', as: 'api_channel' # Channel Feed
    get '/api/:device/:channel_id/:epsiode_id' => 'api#episode', as: 'api_episode' # Web Only (for video page)
    get '/api/authorize/:serial' => 'api#authorize_roku', as: 'api_authorize_roku' # Roku authentication

    get 'video_search' => 'videos#navbar_search'

    get '/watch/live/:channel_id' => 'videos#watch_channel', as: 'watch_channel'

    get '/watch/movies/:movie_id' => 'videos#watch_movie', as: 'watch_movie'

    get '/watch/shows/:show_id' => 'videos#browse_episodes', as: 'browse_episodes'
    get '/watch/shows/:show_id/:episode_number' => 'videos#watch_episode', as: 'watch_episode'

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
