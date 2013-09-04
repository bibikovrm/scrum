class SprintsController < ApplicationController

  menu_item :scrum
  model_object Sprint

  before_filter :find_model_object, :only => [:show, :edit, :update, :destroy]
  before_filter :find_project_from_association, :only => [:show, :edit, :update, :destroy]
  before_filter :find_project_by_project_id, :only => [:index, :new, :create]
  before_filter :find_selected_sprint, :only => [:index]
  before_filter :authorize

  helper :custom_fields
  helper :projects
  include CustomFieldsHelper
  include ProjectsHelper

  def index
  end

  def show
  end

  def new
    @sprint = Sprint.new(:project => @project)
    if params[:create_product_backlog]
      @sprint.name = l(:label_product_backlog)
      @sprint.start_date = @sprint.end_date = Date.today
    end
  end

  def create
    raise "Product backlog is already set" if params[:create_product_backlog] and
                                              !(@project.product_backlog.nil?)
    @sprint = Sprint.new(params[:sprint].merge(:user => User.current, :project => @project))
    if request.post? and @sprint.save
      if params[:create_product_backlog]
        @project.product_backlog = @sprint
        raise "Fail to update project with product backlog" unless @project.save!
      end
      flash[:notice] = l(:notice_successful_create)
      redirect_to settings_project_path(@project, :tab => "sprints")
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def edit
  end

  def update
    if @sprint.update_attributes(params[:sprint])
      flash[:notice] = l(:notice_successful_update)
      redirect_to settings_project_path(@project, :tab => "sprints")
    end
  end

  def destroy
    if @sprint.issues.any?
      flash[:error] = l(:notice_sprint_has_issues)
    else
      @sprint.destroy
    end
  rescue
    flash[:error] = l(:notice_unable_delete_sprint)
  ensure
    redirect_to settings_project_path(@project, :tab => "sprints")
  end

private

  def find_selected_sprint
    if params[:selected_sprint_id].nil? or
       @project.product_backlog.nil? or params[:selected_sprint_id] == @project.product_backlog.id
      @sprint = @project.sprints.max_by(&:end_date)
    else
      @sprint = @project.sprints.find(params[:selected_sprint_id])
    end
  end

end
