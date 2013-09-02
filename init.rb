# encoding: UTF-8

# This plugin should be reloaded in development mode.
if (Rails.env == "development")
  ActiveSupport::Dependencies.autoload_once_paths.reject!{|x| x =~ /^#{Regexp.escape(File.dirname(__FILE__))}/}
end

Issue.send(:include, Scrum::IssuePatch)
Project.send(:include, Scrum::ProjectPatch)
ProjectsHelper.send(:include, Scrum::ProjectsHelperPatch)

require_dependency "scrum/helper_hooks"
require_dependency "scrum/view_hooks"

Redmine::Plugin.register :scrum do
  name              "Scrum Redmine plugin"
  author            "Emilio González Montaña"
  description       "This plugin for Redmine allows to follow Scrum methodology with Redmine projects"
  version           "0.1.0"
  url               "https://redmine.ociotec.com/projects/redmine-plugin-scrum"
  author_url        "http://ociotec.com"
  requires_redmine  :version_or_higher => "2.1.2"

  project_module    :sprints do
    permission      :view_sprints, {:sprints => [:show]}, :public => true
    permission      :edit_sprints, {:sprints => [:index, :new, :create, :edit, :update]}, :require => :member
    permission      :delete_sprints, {:sprints => [:destroy]}, :require => :member
    permission      :view_product_backlog, {:product_backlog => [:index]}, :require => :member
    permission      :edit_product_backlog, {:product_backlog => [:sort]}, :require => :member
  end

  menu :project_menu, :scrum, {:controller => :sprints, :action => :index},
       :caption => :label_scrum, :after => :activity, :param => :project_id

  settings          :default => {"story_points_custom_field" => "",
                                 "task_trakers" => "",
                                 "user_story_trakers" => ""},
                    :partial => "settings/scrum_settings"
end
