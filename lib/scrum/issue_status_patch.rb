require_dependency "issue_status"

module Scrum
  module IssueStatusPatch
    def self.included(base)
      base.class_eval do

        def self.task_statuses
          ids = Setting.plugin_scrum[:task_statuses].collect{|status| status.to_i} || []
          IssueStatus.find(ids, :order => "position ASC")
        end

      end
    end
  end
end
