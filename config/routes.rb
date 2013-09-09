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

post "issues/:id/story_points",
     :controller => :product_backlog, :action => :change_story_points,
     :as => :change_story_points
post "issues/:id/pending_effort",
     :controller => :product_backlog, :action => :change_pending_effort,
     :as => :change_pending_effort
