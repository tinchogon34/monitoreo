Rails.application.routes.draw do
  resources :users, only: [:index], param: :name do
    get 'tasks', on: :member
  end
  resources :tasks, except: [:new, :edit], param: :pid
end
