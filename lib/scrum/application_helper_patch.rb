# Copyright © Emilio González Montaña
# Licence: Attribution & no derivates
#   * Attribution to the plugin web page URL should be done if you want to use it.
#     https://redmine.ociotec.com/projects/redmine-plugin-scrum
#   * No derivates of this plugin (or partial) are allowed.
# Take a look to licence.txt file at plugin root folder for further details.

require_dependency "application_helper"

module Scrum
  module ApplicationHelperPatch
    def self.included(base)
      base.class_eval do

        def link_to_sprint(sprint, include_project_prefix = false)
          if sprint.is_product_backlog
            path = project_product_backlog_index_path(sprint.project)
          else
            path = sprint
          end
          label = h(sprint.name)
          label = "#{sprint.project.name}:#{label}" if include_project_prefix
          return link_to(label, path)
        end

        def link_to_sprint_stats(sprint, include_project_prefix = false)
          if sprint.is_product_backlog
            return nil
          else
            path = stats_sprint_path(sprint)
            label = l(:label_sprint_stats_name, :name => sprint.name)
            label = "#{sprint.project.name}:#{label}" if include_project_prefix
            return link_to(label, path)
          end
        end

        def link_to_sprint_burndown(sprint, include_project_prefix = false)
          if sprint.is_product_backlog
            label = l(:label_product_backlog_burndown_chart)
            path = burndown_project_product_backlog_index_path(sprint.project)
          else
            label = l(:label_sprint_burndown_chart_name, :name => sprint.name)
            path = burndown_sprint_path(sprint)
          end
          label = "#{sprint.project.name}:#{label}" if include_project_prefix
          return link_to(label, path)
        end

        def link_to_release_plan(project, include_project_prefix = false)
          label = l(:label_release_plan)
          label = "#{project.name}:#{label}" if include_project_prefix
          return link_to(label, project_release_plan_path(project))
        end

        def parse_redmine_links_with_scrum(text, default_project, obj, attr, only_path, options)
          result = parse_redmine_links_without_scrum(text, default_project, obj, attr, only_path, options)
          text.gsub!(%r{([\s\(,\-\[\>]|^)(!)?(([a-z0-9\-_]+):)?(sprint|sprint-burndown|sprint-stats|product-backlog|product-backlog-burndown|release-plan)?((#)((\d*)|(current|latest)))(?=(?=[[:punct:]][^A-Za-z0-9_/])|,|\s|\]|<|$)}) do |m|
            leading, project_identifier, element_type, separator, element_id_text = $1, $4, $5, $7, $8
            link = nil
            project = default_project
            if project_identifier
              project = Project.visible.find_by_identifier(project_identifier)
            end
            if project and element_type and element_id_text
              element_id = element_id_text.to_i
              include_project_prefix = (project != default_project)
              case element_type
                when "sprint", "sprint-burndown", "sprint-stats"
                  if ((element_id_text == "latest") or (element_id_text == "current"))
                    sprint = project.last_sprint
                  else
                    sprint = project.sprints.find_by_id(element_id)
                  end
                when "product-backlog", "product-backlog-burndown"
                  sprint = project.product_backlog
              end
              case element_type
                when "sprint"
                  link = link_to_sprint(sprint, include_project_prefix) unless sprint.nil?
                when "sprint-burndown"
                  link = link_to_sprint_burndown(sprint, include_project_prefix) unless sprint.nil?
                when "sprint-stats"
                  link = link_to_sprint_stats(sprint, include_project_prefix) unless sprint.nil?
                when "product-backlog"
                  link = link_to_sprint(sprint, include_project_prefix) unless sprint.nil?
                when "product-backlog-burndown"
                  link = link_to_sprint_burndown(sprint, include_project_prefix) unless sprint.nil?
                when "release-plan"
                  link = link_to_release_plan(project, include_project_prefix) unless project.product_backlog.nil?
              end
            end
            (leading + (link || "#{project_identifier}#{element_type}#{separator}#{element_id_text}"))
          end
          return result
        end
        alias_method_chain :parse_redmine_links, :scrum

        def scrum_tips
          tips = []
          if Scrum::Setting.render_plugin_tips
            # Plugin permissions check.
            unless @project and !(@project.module_enabled?(:scrum))
              scrum_permissions = Redmine::AccessControl.modules_permissions(["scrum"]).select{|p| p.project_module}.collect{|p| p.name}
              active_scrum_permissions = Role.all.collect{|r| r.permissions & scrum_permissions}.flatten
              if active_scrum_permissions.empty?
                tips << l(:label_tip_no_permissions,
                          :link => link_to(l(:label_tip_permissions_link), permissions_roles_path))
              end
            end
            # Minimal plugin settings check.
            plugin_settings_link = link_to(l(:label_tip_plugin_settings_link),
                                           plugin_settings_path(:id => :scrum))
            if Scrum::Setting.story_points_custom_field_id.blank?
              tips << l(:label_tip_no_plugin_setting, :link => plugin_settings_link,
                        :setting => l(:label_setting_story_points_custom_field))
            end
            if Scrum::Setting.pbi_tracker_ids.empty?
              tips << l(:label_tip_no_plugin_setting, :link => plugin_settings_link,
                        :setting => l(:label_pbi_plural))
            end
            if Scrum::Setting.task_tracker_ids.empty?
              tips << l(:label_tip_no_plugin_setting, :link => plugin_settings_link,
                        :setting => l(:label_task_plural))
            end
            if Scrum::Setting.task_status_ids.empty?
              tips << l(:label_tip_no_plugin_setting, :link => plugin_settings_link,
                        :setting => l(:label_setting_task_statuses))
            end
            if Scrum::Setting.pbi_status_ids.empty?
              tips << l(:label_tip_no_plugin_setting, :link => plugin_settings_link,
                        :setting => l(:label_setting_pbi_statuses))
            end
            # Project configuration checks.
            if @project and @project.module_enabled?(:scrum)
              product_backlog_link = link_to(l(:label_tip_product_backlog_link),
                                             project_product_backlog_index_path(@project))
              # PB exists check.
              if @project.product_backlog.nil?
                tips << l(:label_tip_no_product_backlog,
                          :link => link_to(l(:label_tip_new_product_backlog_link),
                                           new_project_sprint_path(@project, :create_product_backlog => true)))
              end
              # At least one Sprint check.
              if @project.sprints.empty?
                tips << l(:label_tip_no_sprints,
                          :link => link_to(l(:label_tip_new_sprint_link),
                                           new_project_sprint_path(@project)))
              end
              # Product backlog (+release plan) checks.
              if @product_backlog and @product_backlog.persisted?
                # No PBIs check.
                if @product_backlog.pbis.empty?
                  tips << l(:label_tip_product_backlog_without_pbis, :link => product_backlog_link)
                end
                # Release plan checks.
                if params[:controller] == "scrum" and params[:action] == "release_plan"
                  # No versions check.
                  if @project.versions.empty?
                    tips << l(:label_tip_project_without_versions,
                              :link => link_to(l(:label_tip_new_version_link),
                                               new_project_version_path(@project)))
                  end
                end
              end
              # Sprint checks.
              if @sprint and @sprint.persisted? and !(@sprint.is_product_backlog?)
                sprint_board_link = link_to(l(:label_tip_sprint_board_link),
                                            sprint_path(@sprint))
                # No PBIs check.
                if @sprint.pbis.empty?
                  tips << l(:label_tip_sprint_without_pbis, :sprint_board_link => sprint_board_link,
                            :product_backlog_link => product_backlog_link)
                end
                # No tasks check.
                if @sprint.tasks.empty?
                  tips << l(:label_tip_sprint_without_tasks, :link => sprint_board_link)
                end
                # No estimated effort check.
                if @sprint.efforts.empty?
                  tips << l(:label_tip_sprint_without_efforts,
                            :link => link_to(l(:label_tip_sprint_effort_link),
                                             edit_effort_sprint_path(@sprint)))
                end
              end
            end
          end
          return tips
        end

      end
    end
  end
end
