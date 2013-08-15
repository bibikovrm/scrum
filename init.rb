# encoding: UTF-8

Redmine::Plugin.register :scrum do
  name        "Scrum Redmine plugin"
  author      "Emilio González Montaña"
  description "This plugin for Redmine allows to follow Scrum methodology with Redmine projects"
  version     "0.1.0"
  url         "https://redmine.ociotec.com/projects/redmine-plugin-scrum"
  author_url  "http://ociotec.com"

  settings    :default => {"sequence_custom_field" => ""},
              :partial => "settings/scrum_settings"
end
