# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :projects do
  resources :sprints, :shallow => true
  post "sprints/change_task_status",
       :controller => :sprints, :action => :change_task_status,
       :as => :sprints_change_task_status

  resources :product_backlog, :only => [:index, :sort] do
    collection do
      post :sort
    end
  end
end
