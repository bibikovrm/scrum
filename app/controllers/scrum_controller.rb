class ScrumController < ApplicationController

  menu_item :scrum

  before_filter :find_issue, :only => [:change_story_points, :change_pending_effort,
                                       :change_assigned_to]
  before_filter :authorize

  helper :scrum

  def change_story_points
    change_custom_field(:story_points_custom_field, @issue, params[:value])
  end

  def change_pending_effort
    change_custom_field(:pending_effort_custom_field, @issue, params[:value])
  end

  def change_assigned_to
    @issue.init_journal(User.current)
    @issue.assigned_to = params[:value].blank? ? nil : User.find(params[:value].to_i)
    @issue.save
    render :partial => "post_its/sprint_board/task",
           :status => 200,
           :locals => {:project => @project,
                       :task => @issue,
                       :user_story_status_id => params[:user_story_status_id],
                       :other_user_story_status_ids => params[:other_user_story_status_ids].split(","),
                       :task_id => params[:task_id]}
  rescue
    render :nothing => true, :status => 503
  end

private

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
