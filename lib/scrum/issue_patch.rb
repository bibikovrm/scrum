require_dependency "issue"

module Scrum
  module IssuePatch
    def self.included(base)
      base.class_eval do

        belongs_to :sprint
        has_many :pending_efforts, :order => "date ASC"

        acts_as_list :scope => :sprint

        safe_attributes :sprint_id, :if => lambda {|issue, user| user.allowed_to?(:edit_issues, issue.project)}

        before_save :update_position, :if => lambda {|issue| issue.sprint_id_changed? and issue.is_pbi?}

        def has_story_points?
          ((!((custom_field_id = Scrum::Setting.story_points_custom_field_id).nil?)) and
           visible_custom_field_values.collect{|value| value.custom_field.id.to_s}.include?(custom_field_id))
        end

        def story_points
          if has_story_points? and
             !((custom_field_id = Scrum::Setting.story_points_custom_field_id).nil?) and
             !((custom_value = self.custom_value_for(custom_field_id)).nil?) and
             !((value = custom_value.value).blank?)
            # Replace invalid float number separatos (i.e. 0,5) with valid separator (i.e. 0.5)
            value.gsub(",", ".")
          end
        end

        def story_points=(value)
          if has_story_points? and
             !((custom_field_id = Scrum::Setting.story_points_custom_field_id).nil?) and
             !((custom_value = self.custom_value_for(custom_field_id)).nil?) and
             custom_value.custom_field.valid_field_value?(value)
            custom_value.value = value
            custom_value.save!
          else
            raise
          end
        end

        def is_pbi?
          tracker.is_pbi?
        end

        def is_task?
          tracker.is_task?
        end

        def tasks_by_status_id
          raise "Issue is not an user story" unless is_pbi?
          statuses = {}
          IssueStatus.task_statuses.each do |status|
            statuses[status.id] = children.select{|issue| (issue.status == status) and issue.visible?}
          end
          statuses
        end

        def doers
          users = []
          users << assigned_to unless assigned_to.nil?
          time_entries = TimeEntry.all(:conditions => {:issue_id => id,
                                                       :activity_id => Issue.doing_activities_ids})
          users.concat(time_entries.collect{|t| t.user}).uniq.sort
        end

        def reviewers
          users = []
          time_entries = TimeEntry.all(:conditions => {:issue_id => id,
                                                       :activity_id => Issue.reviewing_activities_ids})
          users.concat(time_entries.collect{|t| t.user}).uniq.sort
        end

        def post_it_css_class(options = {})
          classes = ["post-it", "big-post-it", tracker.post_it_css_class]
          if is_pbi?
            classes << "sprint-pbi"
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
          doer_or_reviewer_post_it_css_class(:doer)
        end

        def self.reviewer_post_it_css_class
          doer_or_reviewer_post_it_css_class(:reviewer)
        end

        def has_pending_effort?
          is_task? and pending_efforts.any?
        end

        def pending_effort
          if self.is_task? and self.has_pending_effort?
            return pending_efforts.last.effort
          elsif self.is_pbi?
            return self.children.collect{|task| task.pending_effort}.compact.sum
          end
        end

        def pending_effort=(new_effort)
          if is_task? and id and new_effort
            effort = PendingEffort.first(:conditions => {:issue_id => id, :date => Date.today})
            # Replace invalid float number separatos (i.e. 0,5) with valid separator (i.e. 0.5)
            new_effort.gsub!(",", ".")
            if effort.nil?
              date = (pending_efforts.empty? and sprint and sprint.sprint_start_date) ? sprint.sprint_start_date : Date.today
              effort = PendingEffort.new(:issue_id => id, :date => date, :effort => new_effort)
            else
              effort.effort = new_effort
            end
            effort.save!
          end
        end

        def init_from_params(params)
        end

        def inherit_from_issue(source_issue)
          [:priority_id, :category_id, :fixed_version_id, :start_date, :due_date].each do |attribute|
            self.copy_attribute(source_issue, attribute)
          end
          self.custom_field_values = source_issue.custom_field_values.inject({}){|h, v| h[v.custom_field_id] = v.value; h}
        end

        def field?(field)
          self.safe_attribute?(field) and (self.tracker.field?(field) or self.required_attribute?(field))
        end

        def custom_field?(custom_field)
          self.tracker.custom_field?(custom_field)
        end

        def set_on_top
          @set_on_top = true
        end

        def total_time
          the_pending_effort = self.pending_effort.nil? ? 0.0 : self.pending_effort
          if self.is_pbi?
            the_spent_hours = self.children.collect{|task| task.spent_hours}.compact.sum
          elsif self.is_task?
            the_spent_hours = self.spent_hours
          end
          the_spent_hours = the_spent_hours.nil? ? 0.0 : the_spent_hours
          return (the_pending_effort + the_spent_hours)
        end

        def deviation_ratio
          the_estimated_hours = self.estimated_hours.nil? ? 0.0 : self.estimated_hours
          if ((self.is_pbi? or self.is_task?) and (the_estimated_hours > 0.0))
            return ((self.total_time * 100.0) / the_estimated_hours).round
          end
        end

        def has_blocked_field?
          return ((!((custom_field_id = Scrum::Setting.blocked_custom_field_id).nil?)) and
                  visible_custom_field_values.collect{|value| value.custom_field.id.to_s}.include?(custom_field_id))
        end

        def blocked?
          if has_blocked_field? and
              !((custom_field_id = Scrum::Setting.blocked_custom_field_id).nil?) and
              !((custom_value = self.custom_value_for(custom_field_id)).nil?) and
              !((value = custom_value.value).blank?)
            return (value == "1")
          end
        end

        def self.blocked_post_it_css_class
          return doer_or_reviewer_post_it_css_class(:blocked)
        end

        def move_pbi_to(position)
          if !(sprint.nil?) and is_pbi?
            pbi_has_changed = true
            case position
              when "top"
                move_issue_to_the_begin_of_the_sprint
              when "bottom"
                move_issue_to_the_end_of_the_sprint
              else
                pbi_has_changed = false
            end
            save! if pbi_has_changed
          end
        end

        def is_first_pbi?
          min = min_position
          return ((!(position.nil?)) and (!(min.nil?)) and (position <= min))
        end

        def is_last_pbi?
          max = max_position
          return ((!(position.nil?)) and (!(max.nil?)) and (position >= max))
        end

      protected

        def copy_attribute(source_issue, attribute)
          if self.safe_attribute?(attribute) and source_issue.safe_attribute?(attribute)
            self.send("#{attribute}=", source_issue.send("#{attribute}"))
          end
        end

      private

        def update_position
          if sprint_id_was.blank?
            # New PBI into PB or Sprint
            if @set_on_top
              move_issue_to_the_begin_of_the_sprint
            else
              move_issue_to_the_end_of_the_sprint
            end
          elsif sprint and (old_sprint = Sprint.find(sprint_id_was))
            if old_sprint.is_product_backlog
              # From PB to Sprint
              move_issue_to_the_end_of_the_sprint
            elsif sprint.is_product_backlog
              # From Sprint to PB
              move_issue_to_the_begin_of_the_sprint
            else
              # From Sprint to Sprint
              move_issue_to_the_end_of_the_sprint
            end
          end
        end

        def min_position
          min = nil
          sprint.pbis.each do |pbi|
            min = pbi.position if min.nil? or (pbi.position < min)
          end
          return min
        end

        def max_position
          max = nil
          sprint.pbis.each do |pbi|
            max = pbi.position if max.nil? or (pbi.position > max)
          end
          return max
        end

        def move_issue_to_the_begin_of_the_sprint
          min = min_position
          self.position = min.nil? ? 1 : (min - 1)
        end

        def move_issue_to_the_end_of_the_sprint
          max = max_position
          self.position = max.nil? ? 1 : (max + 1)
        end

        def self.doer_or_reviewer_post_it_css_class(type)
          classes = ["post-it"]
          case type
            when :doer
              classes << "doer-post-it"
              classes << Scrum::Setting.doer_color
            when :reviewer
              classes << "reviewer-post-it"
              classes << Scrum::Setting.reviewer_color
            when :blocked
              classes << "blocked-post-it"
              classes << Scrum::Setting.blocked_color
          end
          classes << "post-it-rotation-#{rand(5)}"
          classes.join(" ")
        end

        @@activities = nil
        def self.activities
          unless @@activities
            @@activities = Enumeration.all(:conditions => {:type => "TimeEntryActivity"})
          end
          @@activities
        end

        @@reviewing_activities_ids = nil
        def self.reviewing_activities_ids
          unless @@reviewing_activities_ids
            @@reviewing_activities_ids = Scrum::Setting.verification_activity_ids
          end
          @@reviewing_activities_ids
        end

        @@doing_activities_ids = nil
        def self.doing_activities_ids
          unless @@doing_activities_ids
            reviewing_activities = Enumeration.all(:conditions => {:id => reviewing_activities_ids})
            doing_activities = activities - reviewing_activities
            @@doing_activities_ids = doing_activities.collect{|a| a.id}
          end
          @@doing_activities_ids
        end

      end
    end
  end
end
