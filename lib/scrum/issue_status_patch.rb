# Copyright © Emilio González Montaña
# Licence: Attribution & no derivates
#   * Attribution to the plugin web page URL should be done if you want to use it.
#     https://redmine.ociotec.com/projects/redmine-plugin-scrum
#   * No derivates of this plugin (or partial) are allowed.
# Take a look to licence.txt file at plugin root folder for further details.

require_dependency "issue_status"

module Scrum
  module IssueStatusPatch
    def self.included(base)
      base.class_eval do

        # New parameter to include lost Tasks fake status
        def self.task_statuses(include_lost_tasks=false)
          the_task_statuses = IssueStatus.where(:id => Scrum::Setting.task_status_ids).order("position ASC")

          # Add lost Tasks fake status
          if include_lost_tasks
            the_task_statuses.unshift(IssueStatus.new(name: I18n.t(:label_lost_tasks), id: nil))
          end

          the_task_statuses
        end

        def self.pbi_statuses
          IssueStatus.where(:id => Scrum::Setting.pbi_status_ids).order("position ASC")
        end

        def self.closed_status_ids
          IssueStatus.where(:is_closed => true).collect{|status| status.id}
        end

      end
    end
  end
end
