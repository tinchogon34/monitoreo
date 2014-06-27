Rails.application.routes.draw do
  resources :users, only: [:index, :show], param: :name, constraints: {id: /[^\/]+/} do
    get 'tasks', on: :member
  end
  resources :tasks, except: [:new, :edit], param: :pid
end
