class ProductBacklogController < ApplicationController

  menu_item :scrum

  before_filter :find_project_by_project_id, :only => [:index, :sort]
  before_filter :check_issue_positions, :only => [:index]
  before_filter :authorize

  def index
    @user_stories = Issue.find_all_by_sprint_id(@project.product_backlog, :order => "position ASC")
  end

  def sort
    @user_stories = Issue.find_all_by_sprint_id(@project.product_backlog, :order => "position ASC")
    @user_stories.each do |user_story|
      user_story.position = params["user_story"].index(user_story.id.to_s) + 1
      user_story.save
    end
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

end
