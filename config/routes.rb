Rails.application.routes.draw do
  devise_for :admins
  devise_for :sales_representatives
  devise_for :users

        get 'video_search' => 'videos#navbar_search'


        get '/watch/grid/:category_id' => 'videos#full_grid', as: 'full_grid'

        get '/grid/:id' => 'videos#grid'

        get '/watch/live/:channel_slug' => 'videos#watch_channel', as: 'watch_channel'

        get '/watch/movies/:movie_slug' => 'videos#watch_movie', as: 'watch_movie'

        get '/watch/shows/:show_slug' => 'videos#browse_episodes', as: 'browse_episodes'
        # All or page


        get '/watch/shows/:show_slug/:episode_number' => 'videos#watch_episode', as: 'watch_episode'

        post 'remote_sign_in_for_video' => 'videos#remote_sign_in_for_video'
        post 'remote_sign_in' => 'users#remote_sign_in'

        get 'subscribe_newsletter_footer' => 'users#subscribe_newsletter_footer'
  	# User Methods
    authenticate :user do
        get 'update_show_time' => 'time#update_show'
        get 'mark_episode_complete' => 'time#mark_episode_complete'
        get 'mark_show_complete' => 'time#mark_show_complete'

        get 'submit_broken_link' => 'videos#submit_broken_link'


        get 'update_movie_time' => 'time#update_movie'
        get 'mark_movie_complete' => 'time#mark_movie_complete'


  	  	get 'account' => 'users#account'

        get '/account/devices' => 'users#devices', as: 'my_devices'
        get '/account/billing' => 'users#billing', as: 'my_billing'
        get '/account/support' => 'users#support', as: 'my_support'

        get '/account/new_ticket' => 'users#new_ticket', as: 'user_new_ticket'
        post 'user_create_ticket' => 'support#user_create_ticket'
        get 'user_view_ticket' => 'support#user_view_ticket'
        post 'user_send_message_on_ticket' => 'support#user_send_message'
        post 'user_attach_file_to_ticket' => 'support#user_attach_file'

        get 'view_device/:id' => 'users#view_device', as: 'view_device'
        post 'update_roku' => 'users#update_roku'
        post 'update_device' => 'users#update_device'
        post 'register_new_device' => 'users#register_new_device'
        get 'unlink_device' => 'users#unlink_device'

        post 'update_profile' => 'users#update_profile'

        get 'subscribe' => 'users#subscribe'
        get 'view_plan' => 'users#view_plan'
        post 'add_subscription' => "users#add_subscription"

        get '/account/settings' => 'users#settings', as: 'user_settings'
        post 'user_reset_password' => 'users#reset_password'
        get 'user_subscribe_to_mailchimp' => 'users#subscribe_to_mailchimp'
        get 'user_unsubscribe_from_mailchimp' => 'users#unsubscribe_from_mailchimp'

        get 'start_free_trial' => 'users#start_free_trial'
    end

  	# Admin Methods
    constraints :subdomain => 'admin' do
        scope :module => 'admin', :as => 'admin' do
            authenticate :admin do
                get '/admins/expiry_report' => 'admins#expiry_report', as: 'expiry_report'
                get '/admins/pdf_expiry_report' => 'admins#pdf_expiry_report', as: 'pdf_expiry_report'


                get 'admin_load_devices' => 'admins#load_devices'

                get 'delete_user' => 'admins#delete_user'
                get 'delete_rep' => 'admins#delete_rep'

                post 'create_client_upload' => 'admins#upload_customers'

                get '/admins/migrations/vod/new' => 'vod_migrations#new_vod_upload', as: 'new_vod_upload'
                post 'start_vod_upload' => 'vod_migrations#start_upload'
                get '/admins/migrations/vod' => 'admins#vod_uploads', as: 'vod_uploads'
                get '/admins/migrations/vod/:id' => 'admins#view_vod_upload', as: 'view_vod_upload'

                get '/admins/migrations/client/new' => 'admins#new_client_upload', as: 'new_client_upload'
                post 'start_client_upload' => 'client_migrations#start_upload'
                get '/admins/migrations/client' => 'admins#client_uploads', as: 'client_uploads'
                get '/admins/migrations/client/:id' => 'admins#view_client_upload', as: 'view_client_upload'


                get 'admin_show_existing_grids' => 'admins#show_existing_grids'
                get 'show_sub_expiry' => 'admins#show_sub_expiry'

                mount ResqueWeb::Engine => "/resque_web"
                get '/admins/notifications/view/:id' => 'admin_notifications#notification_redirect', as: 'admin_view_notification'
                get 'clear_notifs' => 'admin_notifications#clear'

          	  	get '/admins' => 'admins#index', as: 'admins'

                get 'admin_view_client_reg_report' => 'admins#view_client_reg_report'
                get 'admin_view_orders_report' => 'admins#view_orders_report'
                get 'admin_view_support_report' => 'admins#view_support_report'

                # General Settings
                get '/admins/settings' => 'admins#general_settings', as: 'general_settings'

                get '/admins/settings/timezone' => 'admins#edit_timezone', as: 'edit_timezone'
                post 'update_default_timezone' => 'admins#update_default_timezone'

                get '/admins/settings/languages' => 'admins#edit_languages', as: 'edit_languages'
                post 'update_languages' => 'admins#update_languages'

                get '/admins/settings/registration_sign_in' => 'admins#edit_registration', as: 'edit_registration'
                post 'update_registration' => 'admins#update_registration'

                get '/admins/settings/payouts' => 'admins#edit_payouts', as: 'edit_payouts'
                post 'update_payout_methods' => 'admins#update_payout_methods'

                get '/admins/settings/device_limit' => 'admins#edit_device_limit', as: 'edit_device_limit'
                post 'update_device_limit' => 'admins#update_device_limit'

                get '/admins/settings/free_trial' => 'admins#edit_free_trial', as: 'edit_free_trial'
                post 'update_free_trial' => 'admins#update_free_trial'

                get '/admins/settings/contact_email' => 'admins#edit_contact_email', as: 'edit_contact_email'
                post 'update_contact_email' => 'admins#update_contact_email'

                get '/admins/settings/wd_limits' => 'admins#edit_wd_limits', as: 'edit_wd_limits'
                post 'update_lower_wd_limit' => 'admins#update_lower_wd_limit'
                post 'update_upper_wd_limit' => 'admins#update_upper_wd_limit'

                get '/admins/settings/footer' => 'admins#edit_footer_content', as: 'edit_footer_content'
                post 'update_footer_content' => 'admins#update_footer_content'


          		# Manage Users
          		get '/admins/users' => 'admins#users', as: 'search_users'
                get '/admins/users/all' => 'admins#all_users', as: 'all_users'
                get 'admin_search_users_table' => 'admins#search_users_table'
          		get 'side_search_users' => 'admins#search_users'
                get '/admins/users/profile/:id' => 'admins#view_user', as: 'view_user'
                get '/admins/users/transactions/:id' => 'admins#view_user_transactions', as: 'view_user_transactions'
                get '/admins/users/devices/:id' => 'admins#view_user_devices', as: 'view_user_devices'
                get '/admins/users/notes/:id' => 'admins#view_user_notes', as: 'view_user_notes'
                get '/admins/users/subscription_adjustment/:id' => 'admins#view_user_subscription', as: 'view_user_subscription'
                get '/admins/users/balance_adjustment/:id' => 'admins#view_user_balance', as: 'view_user_balance'

                get 'reset_user_password' => 'admins#reset_user_password'
                post 'manual_reset_user_password' => 'admins#manual_reset_user_password'

                post 'update_user_roku_account' => 'admins#update_user_roku_account'
                post 'update_user_language' => 'admins#update_user_language'

                post 'admin_update_user_profile' => 'admins#update_user_profile'
                post 'admin_update_user_mailing' => 'admins#update_user_mailing'
                post 'extend_user_subscription' => 'admins#extend_user_subscription'
                get 'cancel_user_subscription' => 'admins#cancel_user_subscription'
                post 'update_user_balance' => 'admins#update_user_balance'
                post 'admin_create_transaction' => 'admins#create_transaction'
                post 'admin_register_device' => 'admins#register_device'
                get 'admin_unlink_device' => 'admins#unlink_device'
                get 'admin_toggle_user_status' => 'admins#toggle_user_status'

                post 'add_note_to_user' => 'users#add_note'
                post 'add_image_to_note' => 'users#add_image_to_note'
                post 'update_note' => 'users#update_note'
                post 'add_image_to_existing_note' => 'users#add_image_to_existing_note'
                get 'delete_note_file' => 'users#delete_note_file'
                get 'delete_note' => 'users#delete_note'
                get 'delete_unsaved_note' => 'users#delete_unsaved_note'

                get 'admin_choose_plan' => 'admins#choose_plan'
                post 'admin_add_subscription' => 'admins#add_subscription'
                post 'admin_add_subscription_user' => 'admins#add_subscription_user'

          		get '/admins/new_user' => 'admins#new_user', as: 'new_user'
          		post 'admin_create_user' => 'admins#create_user'

                get '/admins/users/pending_payments' => 'admins#user_payment_queue'

                # Transactions
                get '/admins/orders' => 'admins#orders', as: 'orders'
                get '/admins/orders/new' => 'admins#new_transaction', as: 'new_tx'
                post 'admin_create_transaction' => 'admins#create_transaction'
                get '/admins/orders/pending' => 'admins#pending_transactions', as: 'pending_tx'
                get '/admins/orders/paid' => 'admins#paid_transactions', as: 'paid_tx'
                get '/admins/orders/refunded' => 'admins#refunded_transactions', as: 'refunded_tx'
                get '/admins/orders/cancelled' => 'admins#cancelled_transactions', as: 'cancelled_tx'
                get '/admins/orders/view/:id' => 'transactions#show', as: 'view_tx'
                post 'update_transaction_dates' => 'transactions#update_dates'

                post 'create_tx_standalone' => 'transactions#create_standalone'

                post 'create_tx_user' => 'transactions#create_user'

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
                get 'delete_channel' => 'videos#delete_channel'

                post 'add_show' => 'videos#add_show'
                post 'update_show' => 'videos#update_show'
                post 'update_show_image' => 'videos#update_show_image'
                post 'update_show_banner' => 'videos#update_show_banner'
                get 'delete_show' => 'videos#delete_show'

                get 'search_shows' => 'videos#search_shows'
                get 'search_episodes' => 'videos#search_episodes'
                get 'delete_episode' => 'videos#delete_episode'

                post 'add_episode' => 'videos#add_episode'
                post 'update_episode' => 'videos#update_episode'
                get 'view_episode' => 'videos#view_episode'

                post 'add_channel' => 'videos#add_channel'
                post 'update_channel' => 'videos#update_channel'
                post 'update_channel_image' => 'videos#update_channel_image'
                post 'update_channel_banner' => 'videos#update_channel_banner'

                get 'search_channels' => 'videos#search_channels'

                post 'add_movie' => 'videos#add_movie'
                post 'update_movie' => 'videos#update_movie'
                post 'update_movie_image' => 'videos#update_movie_image'
                post 'update_movie_banner' => 'videos#update_movie_banner'
                get 'delete_movie' => 'videos#delete_movie'

                get 'search_movies' => 'videos#search_movies'
                get 'admin_show_all_grids' => 'admins#show_all_grids'
                get 'admin_show_existing_grids' => 'admins#show_existing_grids'

                get '/admins/videos/broken' => 'admins#broken_links', as: 'admin_broken_links'
                get 'mark_broken_as_resolved' => 'admins#mark_broken_as_resolved'

                get '/admins/videos/grids/all' => 'admins#all_grids', as: 'admin_all_grids'
                get '/admins/videos/grids/home' => 'admins#home_grid', as: 'admin_home_grid'
                get '/admins/videos/grids/view/:id' => 'admins#view_grid', as: 'admin_view_grid'
                post 'admin_update_grid' => 'admins#update_grid'
                post 'admin_update_grid_image' => 'admins#update_grid_image'
                get '/admins/videos/grids/new' => 'admins#new_grid', as: 'admin_new_grid'
                post 'admin_create_grid' => 'admins#create_grid'
                get 'delete_grid' => 'admins#delete_grid'

                post 'add_grid' => 'videos#add_grid'
                post 'update_grid' => 'videos#update_grid'

                get 'refresh_grid_view' => 'videos#refresh_grid'

              	# Manage Sales Reps
              	get '/admins/sales_reps' => 'admins#sales_reps', as: 'search_reps_main'
              	get 'search_reps' => 'admins#search_reps'
              	get '/admins/sales_reps/view/:id' => 'admins#view_rep', as: 'view_rep'
              	get '/admins/new_sales_rep' => 'admins#new_sales_rep', as: 'new_rep'
              	post 'admin_create_sales_rep' => 'admins#create_sales_rep'

                get 'reset_rep_password' => 'admins#reset_rep_password'
                post 'manual_reset_rep_password' => 'admins#manual_reset_rep_password'

                post 'admin_update_rep_profile' => 'admins#update_rep_profile'
                post 'admin_update_rep_mailing' => 'admins#update_rep_mailing'
                post 'admin_update_rep_commission' => 'admins#update_rep_commission'

                get 'admin_rep_current_balance' => 'admins#rep_current_balance'
                get 'admin_rep_pending_balance' => 'admins#rep_pending_balance'
                get 'admin_rep_pending_withdrawals' => 'admins#rep_pending_withdrawals'
                get 'admin_rep_total_payout' => 'admins#rep_total_payout'

                get 'admin_view_pending_balance_details' => 'admins#view_pending_balance_details'
                get 'admin_view_current_balance_details' => 'admins#view_current_balance_details'
                get 'admin_view_pending_withdrawals_details' => 'admins#view_pending_withdrawals_details'
                get 'admin_view_total_payout_details' => 'admins#view_total_payout_details'

              	# Manage Plans/Invoice
              	get '/admins/financial' => 'admins#plans', as: 'financial_settings'
              	post 'update_plan' => 'plans#update'
                post 'update_paypal' => 'admins#update_paypal'

                post 'update_invoice_details' => 'admins#update_invoice_details'
                post 'upload_invoice_logo' => 'admins#upload_invoice_logo'

                # Activity Feed
                get 'load_activity_feed' => 'feed#load'
                get 'load_admin_activity_feed' => 'feed#load_admin'
                get 'refresh_feed' => 'feed#refresh'
                get '/admins/view_update' => 'feed#view_update', as: 'view_update'

                # Sales Rep Withdrawals
                get '/admins/sales_reps/payment_requests' => 'admins#payment_requests', as: 'sales_payment_requests'
                get '/admins/sales_reps/payment_requests/:id' => 'admins#view_request', as: 'view_request'
                get 'approve_request' => 'admins#approve_request'
                get 'deny_request' => 'admins#deny_request'

                get '/admins/sales_reps/payments' => 'admins#payments', as: 'all_payments'

                get '/admins/sales_reps/invoices/withdrawals/:id' => 'admins#view_withdrawal_invoice', as: 'admin_view_withdrawal_invoice'
                get '/admins/sales_reps/invoices/transactions' => 'admins#view_transactions_over_period', as: 'admin_rep_tx_invoice'

                # Support
                get '/admins/support' => 'admins#support', as: 'admin_support'
                get '/admins/support/create' => 'admins#new_ticket', as: 'admin_new_ticket'
                post 'admin_create_ticket' => 'support#admin_create_ticket'
                get 'search_users_for_ticket_order' => 'admins#search_users_for_ticket_order'
                get '/admins/support/new' => 'admins#new_tickets', as: 'admin_new_tickets'
                get '/admins/support/priority' => 'admins#priority_tickets', as: 'admin_priority_tickets'
                get '/admins/support/closed' => 'admins#closed_tickets', as: 'admin_closed_tickets'
                get '/admins/support/open' => 'admins#open_tickets', as: 'admin_open_tickets'
                get '/admins/support/archived' => 'admins#archived_tickets', as: 'admin_archived_tickets'

                get '/admins/support/ticket/:id' => 'support#admin_view_ticket', as: 'admin_view_ticket'
                get 'accept_ticket' => 'support#accept_ticket'
                get 'close_ticket' => 'support#close_ticket'
                get 'reopen_ticket' => 'support#reopen_ticket'
                post 'update_ticket_status' => 'support#update_ticket_status'
                get 'delete_ticket' => 'support#delete_ticket'

                post 'admin_send_message_on_ticket' => 'support#admin_send_message'
                post 'admin_attach_file_to_ticket' => 'support#admin_attach_file'

                get 'issue_refund' => 'support#issue_refund'


                # Permissions
                get '/admins/roles' => 'admins#roles', as: 'admin_roles'

                get '/admins/roles/new' => 'admins#new_admin_role', as: 'new_role'
                post 'create_admin_role' => 'admins#create_admin_role'

                get '/admins/roles/:id' => 'admins#role', as: 'role'
                post 'update_role' => 'admins#update_role'
                get 'delete_role' => 'admins#delete_role'

                post 'update_admin_permissions' => 'permissions#update'

                # Manage Admins
                get '/admins/manage_admins' => 'admins#manage_admins', as: 'manage_admins'
                get '/admins/manage_admins/new' => 'admins#new_admin', as: 'new_admin'
                post 'create_admin' => 'admins#create_admin'

                get '/admins/manage_admins/view/:id' => 'admins#view_admin', as: 'view_admin'
                post 'update_admin' => 'admins#update_admin'
                get 'remove_admin' => 'admins#remove_admin'
                get 'reset_admin_password' => 'admins#send_password_reset'

                # Mail Settings
                get '/admins/mail' => 'admins#mail_settings', as: 'mail_settings'
                post 'update_mailchimp' => 'admins#update_mailchimp'
                post 'update_smtp' => 'admins#update_smtp'
                post 'update_send_address' => 'admins#update_send_address'

                get '/admins/mail/markup' => 'admins#mail_markup', as: 'mail_markup'
                post 'update_mail_css' => 'admins#update_mail_css'
                post 'update_mail_header' => 'admins#update_mail_header'
                post 'update_mail_footer' => 'admins#update_mail_footer'

                get '/admins/mail/template/:id' => 'admins#mail_template', as: 'mail_template'
                post 'update_mail_template_body' => 'admins#update_mail_template_body'
                post 'update_mail_template_css' => 'admins#update_mail_template_css'
                post 'update_mail_template_subject' => 'admins#update_mail_template_subject'

                get 'admin_view_device/:id' => 'admins#view_device', as: 'admin_view_device'
                post 'admin_update_device_serial' => 'admins#update_device_serial'
                post 'admin_update_web_sub' => 'admins#update_web_sub'

                # System
                get '/admins/background_tasks_status' => 'admins#bg_tasks', as: 'bg_tasks'
                get '/admins/system_log' => 'admins#sys_log', as: 'sys_log'
            end
        end

        authenticate :sales_representative do
        	get 'sales_reps' => 'sales_reps#index'

            get '/sales_reps/profile' => 'sales_reps#profile', as: 'rep_profile'
            post 'update_sales_rep_profile' => 'sales_reps#update_profile'
            post 'update_sales_rep_address' => 'sales_reps#update_address'

        	get '/sales_reps/register' => 'sales_reps#register'
        	post 'register_step_one' => 'sales_reps#register_step_one'
        	get 'sales_rep_choose_plan' => 'sales_reps#choose_plan'
        	post 'sales_rep_add_subscription' => 'sales_reps#add_subscription'

        	get '/sales_reps/withdrawals' => 'sales_reps#transactions', as: 'sales_rep_financial'
            get '/sales_reps/withdrawals/:id' => 'sales_reps#view_withdrawal', as: 'rep_view_request'

        	get '/sales_reps/settings' => 'sales_reps#settings'

            get '/sales_reps/support' => 'sales_reps#support', as: 'sales_rep_support'
            get '/sales_reps/support/archived_tickets' => 'sales_reps#archived_tickets', as: 'sales_rep_archived_tickets'
            get '/sales_reps/support/closed_tickets' => 'sales_reps#closed_tickets', as: 'sales_rep_closed_tickets'
            get '/sales_reps/support/new_ticket' => 'sales_reps#new_ticket', as: 'sales_rep_new_ticket'
            get '/sales_reps/support/ticket/:id' => 'support#sales_rep_view_ticket', as: 'sales_rep_view_ticket'
            post 'sales_rep_create_ticket' => 'support#sales_rep_create_ticket'

            post 'sales_rep_send_message_on_ticket' => 'support#sales_rep_send_message'
            post 'sales_rep_attach_file_to_ticket' => 'support#sales_rep_attach_file'

            get 'rep_pending_balance' => 'sales_reps#pending_balance'
            get 'rep_current_balance' => 'sales_reps#current_balance'
            get 'rep_pending_withdrawals' => 'sales_reps#pending_withdrawals'
            get 'rep_total_payout' => 'sales_reps#total_payout'
            get 'rep_meets_limit' => 'sales_reps#meets_limit'
            get 'rep_view_invoice' => 'sales_reps#view_withdrawal_invoice'

            get 'view_pending_balance_details' => 'sales_reps#view_pending_balance_details'
            get 'view_current_balance_details' => 'sales_reps#view_current_balance_details'
            get 'view_pending_withdrawals_details' => 'sales_reps#view_pending_withdrawals_details'
            get 'view_total_payout_details' => 'sales_reps#view_total_payout_details'

            get '/sales_reps/new_withdrawal' => 'sales_reps#new_withdrawal', as: 'rep_new_withdrawal'
            post 'create_withdrawal' => 'sales_reps#create_withdrawal'

            get '/sales_reps/invoices/withdrawals/:id' => 'sales_reps#view_withdrawal_invoice', as: 'rep_view_withdrawal_invoice'
            get '/sales_reps/invoices/transactions' => 'sales_reps#view_transactions_over_period', as: 'rep_tx_invoice'
        end
    end

    # Roku API (All XML)

        # Home Grid
        get '/api/v1/roku/grid/home' => 'roku_api#home_grid', as: 'roku_home_grid' #returns XML

        # View Grid
        get '/api/v1/roku/grid/view/:id' => 'roku_api#view_grid', as: 'roku_view_grid' #returns XML

        # View Live Channel
        get '/api/v1/roku/channel/:id' => 'roku_api#view_channel', as: 'roku_view_channel' #returns XML

        # View TV/Radio Show
        get '/api/v1/roku/show/:id' => 'roku_api#view_show', as: 'roku_view_show' #returns XML

        # View Movie
        get '/api/v1/roku/movie/:id' => 'roku_api#view_movie' #returns XML

    # Other device API (Uses JSON instead).
    # Roku devices MAY use this method if needed. The roku serial number will be used in place of the token.

        # Home Grid
        get '/api/v1/json/grid/home'=> 'api#home_grid' #returns JSON

        # View Grid
        get '/api/v1/json/grid/view/:id' => 'api#view_grid', as: 'json_view_grid' #returns JSON

        # View Live Channel
        get '/api/v1/json/channel/:id' => 'api#view_channel' #returns JSON

        # View TV/Radio Show
        get '/api/v1/json/show/:id' => 'api#view_show' #returns JSON

        # View TV/Radio Show Episode
        get '/api/v1/json/show/:show_id/:episode_number' => 'api#view_episode' #returns JSON

        # View Movie
        get '/api/v1/json/movie/:id' => 'api#view_movie' #returns JSON

        # Authenticate Device
        post '/api/v1/json/authenticate' => 'api#authenticate' #returns JSON with token for reauthentication later
        get '/api/v1/json/authenticate' => 'api#authenticate' #returns JSON with token for reauthentication later

    post 'create_new_user' => 'users#create_new'

    get 'free_trial' => 'users#free_trial'
    post 'free_trial_1' => 'users#free_trial_1'
    get 'free_trial_2' => 'users#free_trial_2'
    get 'free_trial_3' => 'users#free_trial_3'
    get 'free_trial_4' => 'users#free_trial_4'

    get 'view_invoice/:id' => 'transactions#view_invoice', as: 'view_invoice'
    get 'view_user_invoice/:id' => 'transactions#view_all', as: 'view_user_invoice'

    get 'search_suggestions' => 'videos#search_suggestions'

    get 'activate_roku' => 'users#roku_demo'
    get 'contact' => 'users#contact'
    post 'send_contact_message' => 'users#send_contact_message'

  root :to => 'videos#landing'

end
