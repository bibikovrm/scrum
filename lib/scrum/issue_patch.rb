require_dependency "issue"

module Scrum
  module IssuePatch
    def self.included(base)
      base.class_eval do

        belongs_to :sprint

        acts_as_list scope: :sprint

        safe_attributes :sprint_id, :if => lambda {|issue, user| user.allowed_to?(:edit_issues, issue.project)}

        def story_points
          if !((custom_field_id = Setting.plugin_scrum[:story_points_custom_field]).nil?) and
             !((custom_value = self.custom_value_for(custom_field_id)).nil?) and
             !((value = custom_value.value).blank?)
            value.to_i
          else
            nil
          end
        end

        def is_user_story?
          tracker.is_user_story?
        end

        def tasks_by_status_id
          raise "Issue is not an user story" unless is_user_story?
          statuses = {}
          IssueStatus.task_statuses.each do |status|
            statuses[status.id] = children.select{|issue| (issue.status == status) and issue.visible?}
          end
          statuses
        end

        def doers
          users = []
          users << assigned_to unless assigned_to.nil?
          activities = Enumeration.all(:conditions => {:type => "TimeEntryActivity"})
          reviewing_activities_ids = Setting.plugin_scrum[:verification_activities].collect{|activity| activity.to_i}
          reviewing_activities = Enumeration.all(:conditions => {:id => reviewing_activities_ids})
          doing_activities = activities - reviewing_activities
          doing_activities_ids = doing_activities.collect{|a| a.id}
          time_entries = TimeEntry.all(:conditions => {:issue_id => self.id, :activity_id => doing_activities_ids})
          users.concat(time_entries.collect{|t| t.user})
          users.uniq.sort
        end

        def reviewers
          users = []
          activities = Enumeration.all(:conditions => {:type => "TimeEntryActivity"})
          reviewing_activities_ids = Setting.plugin_scrum[:verification_activities].collect{|activity| activity.to_i}
          time_entries = TimeEntry.all(:conditions => {:issue_id => self.id, :activity_id => reviewing_activities_ids})
          users.concat(time_entries.collect{|t| t.user})
          users.uniq.sort
        end

        def post_it_css_class(options = {})
          classes = ["post-it", "big-post-it", tracker.post_it_css_class]
          if is_user_story?
            classes << "sprint-user-story"
            if options[:draggable] and
               User.current.allowed_to?(:edit_product_backlog, project) and
               editable?
              classes << "post-it-vertical-move-cursor"
            end
          else
            classes << "sprint-task"
            if options[:draggable] and
               User.current.allowed_to?(:edit_sprint_board, project) and
               editable?
              classes << "post-it-horizontal-move-cursor"
            end
          end
          classes << "post-it-rotation-#{rand(5)}" if options[:rotate]
          classes << "post-it-small-rotation-#{rand(5)}" if options[:small_rotate]
          classes << "post-it-scale" if options[:scale]
          classes << "post-it-small-scale" if options[:small_scale]
          classes.join(" ")
        end

        def self.doer_post_it_css_class
          doer_or_reviewer_post_it_css_class(true)
        end

        def self.reviewer_post_it_css_class
          doer_or_reviewer_post_it_css_class(false)
        end

      private

        def self.doer_or_reviewer_post_it_css_class(doer)
          classes = ["post-it", doer ? "doer-post-it" : "reviewer-post-it"]
          if doer
            classes << (Setting.plugin_scrum["doer_color"] ||
                        Redmine::Plugin::registered_plugins[:scrum].settings[:default]["doer_color"])
          else
            classes << (Setting.plugin_scrum["reviewer_color"] ||
                        Redmine::Plugin::registered_plugins[:scrum].settings[:default]["reviewer_color"])
          end
          classes << "post-it-rotation-#{rand(5)}"
          classes.join(" ")
        end

      end
    end
  end
end
