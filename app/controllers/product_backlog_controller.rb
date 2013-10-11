class ProductBacklogController < ApplicationController

  menu_item :scrum
  model_object Issue

  before_filter :find_project_by_project_id, only: [:index, :sort, :new_pbi, :create_pbi]
  before_filter :find_product_backlog, only: [:index, :render_pbi, :sort, :new_pbi, :create_pbi]
  before_filter :find_user_stories, only: [:index, :sort]
  before_filter :check_issue_positions, only: [:index]
  before_filter :authorize

  helper :scrum

  def index
  end

  def sort
    @user_stories.each do |user_story|
      user_story.init_journal(User.current)
      user_story.position = params["user_story"].index(user_story.id.to_s) + 1
      user_story.save!
    end
    render :nothing => true
  end

  def new_pbi
    @pbi = Issue.new
    @pbi.project = @project
    @pbi.author = User.current
    @pbi.tracker = @project.trackers.find(params[:tracker_id])
    @pbi.sprint = @product_backlog

    respond_to do |format|
      format.html
      format.js
    end
  end

  def create_pbi
    begin
      @continue = !(params[:create_and_continue].nil?)
      @pbi = Issue.new(params[:issue])
      @pbi.project = @project
      @pbi.author = User.current
      @pbi.sprint = @product_backlog
      @pbi.save!
      @pbi.story_points = params[:issue][:story_points]
    rescue Exception => @exception
    end
    respond_to do |format|
      format.js
    end
  end

private

  def find_product_backlog
    @product_backlog = @project.product_backlog
    raise if @product_backlog.nil?
  rescue
    render_404
  end

  def find_user_stories
    @user_stories = @product_backlog.user_stories
  rescue
    render_404
  end

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
