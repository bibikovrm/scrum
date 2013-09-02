require_dependency "issue"

module Scrum
  module IssuePatch
    def self.included(base)
      base.class_eval do

        belongs_to :sprint

        acts_as_list scope: :sprint

        safe_attributes :sprint_id, :if => lambda {|issue, user| user.allowed_to?(:edit_issues, issue.project)}

        def story_points
          if !((custom_field_id = Setting.plugin_scrum[:story_points_custom_field]).nil?)
            if !((value = self.custom_value_for(custom_field_id)).nil?)
              value.value.to_i
            else
              nil
            end
          elsif !(estimated_hours.nil?)
            estimated_hours.to_i
          else
            nil
          end
        end

      end
    end
  end
end
