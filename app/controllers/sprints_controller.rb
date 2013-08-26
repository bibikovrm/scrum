class SprintsController < ApplicationController

  model_object Sprint

  before_filter :find_model_object, :except => [:index, :new, :create]
  before_filter :find_project_from_association, :except => [:index, :new, :create]
  before_filter :find_project, :only => [:index]
  before_filter :find_project_by_project_id, :only => [:new, :create]
  before_filter :authorize

  helper :custom_fields
  helper :projects
  include CustomFieldsHelper
  include ProjectsHelper

  def index
    redirect_to :controller => :projects, :action => :settings, :tab => "sprints", :id => @project
  end

  def show
  end

  def new
    @sprint = Sprint.new(:project => @project)
  end

  def create
    @sprint = Sprint.new(params[:sprint].merge(:user => User.current, :project => @project))
    if request.post? and @sprint.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to :controller => :projects, :action => :settings, :tab => "sprints", :id => @project
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

end
