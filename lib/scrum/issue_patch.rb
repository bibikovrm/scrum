require_dependency "issue"

module Scrum
  module IssuePatch
    def self.included(base)
      base.class_eval do

        belongs_to :sprint

        safe_attributes :sprint_id, :if => lambda {|issue, user| user.allowed_to?(:edit_issues, issue.project)}

      end
    end
  end
end
