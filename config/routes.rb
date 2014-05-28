Rails.application.routes.draw do
  devise_for :admins
  devise_for :sales_representatives
  devise_for :users
  
  get 'search_suggestions' => 'videos#search_suggestions'
  
  post 'create_new_user' => 'users#create_new'
  
  root :to => 'videos#landing'
  
end
