# encoding: UTF-8

Issue.send(:include, Scrum::IssuePatch)
Project.send(:include, Scrum::ProjectPatch)

Redmine::Plugin.register :scrum do
  name              "Scrum Redmine plugin"
  author            "Emilio González Montaña"
  description       "This plugin for Redmine allows to follow Scrum methodology with Redmine projects"
  version           "0.1.0"
  url               "https://redmine.ociotec.com/projects/redmine-plugin-scrum"
  author_url        "http://ociotec.com"
  requires_redmine  :version_or_higher => "2.1.2"

  settings          :default => {"sequence_custom_field" => ""},
                    :partial => "settings/scrum_settings"
end
