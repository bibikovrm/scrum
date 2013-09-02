# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :projects do
  resources :sprints, :shallow => true
  resources :product_backlog, :only => [:index, :sort] do
    collection do
      post :sort
    end
  end
end
