# encoding: UTF-8

# This plugin should be reloaded in development mode.
if (Rails.env == "development")
  ActiveSupport::Dependencies.autoload_once_paths.reject!{|x| x =~ /^#{Regexp.escape(File.dirname(__FILE__))}/}
end

Issue.send(:include, Scrum::IssuePatch)
Project.send(:include, Scrum::ProjectPatch)
ProjectsHelper.send(:include, Scrum::ProjectsHelperPatch)

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
  end

  settings          :default => {"sequence_custom_field" => ""},
                    :partial => "settings/scrum_settings"
end
