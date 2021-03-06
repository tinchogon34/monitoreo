Rails.application.routes.draw do
  constraints subdomain: 'api' do
    scope module: 'api' do
      namespace :v1 do
        resources :users, only: [:index, :show], param: :name, constraints: {id: /[^\/]+/} do
          get 'tasks', on: :member
        end
        resources :tasks, except: [:new, :edit], param: :pid
      end
    end
  end
  match "*path", to: "application#catch_404", via: :all
  root "application#catch_404"
end
