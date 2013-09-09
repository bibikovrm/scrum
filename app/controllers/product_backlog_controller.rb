class ProductBacklogController < ApplicationController

  menu_item :scrum

  before_filter :find_project_by_project_id, :only => [:index, :sort]
  before_filter :check_issue_positions, :only => [:index]
  before_filter :find_issue, :only => [:change_story_points, :change_pending_effort]
  before_filter :authorize

  helper :scrum

  def index
    @user_stories = @project.product_backlog.user_stories
  end

  def sort
    @project.product_backlog.user_stories.each do |user_story|
      user_story.init_journal(User.current)
      user_story.position = params["user_story"].index(user_story.id.to_s) + 1
      user_story.save!
    end
    render :nothing => true
  end

  def change_story_points
    change_custom_field(:story_points_custom_field, @issue, params[:value])
  end

  def change_pending_effort
    change_custom_field(:pending_effort_custom_field, @issue, params[:value])
  end

private

  def check_issue_positions
    check_issue_position(Issue.find_all_by_sprint_id_and_position(@project.product_backlog, nil))
  end

  def check_issue_position(issue)
    if issue.is_a?(Issue)
      if issue.position.nil?
        issue.reset_positions_in_list
        issue.save!
        issue.reload
      end
    elsif issue.is_a?(Array)
      issue.each do |i|
        check_issue_position(i)
      end
    else
      raise "Invalid type: #{issue.inspect}"
    end
  end

  def change_custom_field(setting, issue, value)
    status = 503
    if !((custom_field_id = Setting.plugin_scrum[setting]).nil?) and
       !((custom_field = CustomField.find(custom_field_id)).nil?) and
       custom_field.validate_field_value(value).empty?
      issue.custom_field_values = {custom_field_id => value}
      issue.save_custom_field_values
      status = 200
    end
    render :nothing => true, :status => status
  end

end
