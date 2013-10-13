# encoding: UTF-8

# This plugin should be reloaded in development mode.
if (Rails.env == "development")
  ActiveSupport::Dependencies.autoload_once_paths.reject!{|x| x =~ /^#{Regexp.escape(File.dirname(__FILE__))}/}
end

Issue.send(:include, Scrum::IssuePatch)
IssueQuery.send(:include, Scrum::IssueQueryPatch)
IssuesController.send(:include, Scrum::IssuesControllerPatch)
IssueStatus.send(:include, Scrum::IssueStatusPatch)
Project.send(:include, Scrum::ProjectPatch)
ProjectsHelper.send(:include, Scrum::ProjectsHelperPatch)
Tracker.send(:include, Scrum::TrackerPatch)
User.send(:include, Scrum::UserPatch)

require_dependency "scrum/helper_hooks"
require_dependency "scrum/view_hooks"

Redmine::Plugin.register :scrum do
  name              "Scrum Redmine plugin"
  author            "Emilio González Montaña"
  description       "This plugin for Redmine allows to follow Scrum methodology with Redmine projects"
  version           "0.2.0"
  url               "https://redmine.ociotec.com/projects/redmine-plugin-scrum"
  author_url        "http://ociotec.com"
  requires_redmine  :version_or_higher => "2.3.0"

  project_module    :scrum do
    permission      :manage_sprints,
                    {sprints: [:new, :create, :edit, :update, :destroy, :edit_effort, :update_effort]},
                    require: :member
    permission      :view_sprint_board,
                    {sprints: [:index, :show]}
    permission      :edit_sprint_board,
                    {sprints: [:change_task_status, :new_pbi, :create_pbi],
                     scrum: [:change_story_points, :change_pending_effort, :change_assigned_to,
                             :create_time_entry]},
                    require: :member
    permission      :view_burndown,
                    {sprints: [:burndown_index, :burndown, :burndown_graph]}
    permission      :view_product_backlog,
                    {product_backlog: [:index]}
    permission      :edit_product_backlog,
                    {product_backlog: [:sort, :new_pbi, :create_pbi]},
                    require: :member
  end

  menu :project_menu, :scrum, {:controller => :sprints, :action => :index},
       :caption => :label_scrum, :after => :activity, :param => :project_id

  settings          :default => {"doer_color" => "post-it-color-5",
                                 "reviewer_color" => "post-it-color-3",
                                 "story_points_custom_field" => "",
                                 "task_statuses" => "",
                                 "task_trakers" => "",
                                 "pbi_trakers" => "",
                                 "verification_activities" => ""},
                    :partial => "settings/scrum_settings"
end
