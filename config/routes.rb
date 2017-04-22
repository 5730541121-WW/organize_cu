Rails.application.routes.draw do
  resources :codes
  resources :course_categories
  resources :belong_tos
  resources :groups
  resources :advisors
  resources :log_breaks
  resources :rules
  resources :personal_leaves
  resources :sick_leaves
  resources :leaves
  resources :competitions
  resources :activities
  resources :portfolios
  resources :gpas
  resources :students
  resources :schedules
  resources :time_slots
  resources :enrollments
  resources :sections
  resources :requires
  resources :courses
  resources :curriculums
  resources :departments
  resources :personnels

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'static_pages#index'

  get 'sessions/new'
  post '/signup', to: 'users#create'

  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  get '/searchindiv', to: 'viewindiv#new'
  post '/searchindiv', to: 'viewindiv#search'

  post '/student_pdf', to: 'students#save'
  post '/personnel_pdf', to: 'personnels#save'
end
