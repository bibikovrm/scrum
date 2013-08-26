# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :projects do
  resources :sprints, :except => [:index, :show, :edit, :update, :destroy]
end

resources :sprints, :only => [:show, :edit, :update, :destroy]
