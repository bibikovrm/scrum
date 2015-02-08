require_dependency "application_helper"

module Scrum
  module ApplicationHelperPatch
    def self.included(base)
      base.class_eval do

        def link_to_sprint(sprint)
          if sprint.is_product_backlog
            path = project_product_backlog_index_path(sprint.project)
          else
            path = sprint
          end
          return link_to(h(sprint.name), path)
        end

        def parse_redmine_links_with_scrum(text, default_project, obj, attr, only_path, options)
          result = parse_redmine_links_without_scrum(text, default_project, obj, attr, only_path, options)
          text.gsub!(%r{([\s\(,\-\[\>]|^)(!)?(([a-z0-9\-_]+):)?(sprint|product-backlog)?((#)(\d*))(?=(?=[[:punct:]][^A-Za-z0-9_/])|,|\s|\]|<|$)}) do |m|
            leading, project_identifier, element_type, separator, element_id_text = $1, $4, $5, $7, $8
            link = nil
            project = default_project
            if project_identifier
              project = Project.visible.find_by_identifier(project_identifier)
            end
            if project and element_type and element_id_text
              element_id = element_id_text.to_i
              case element_type
                when "sprint"
                  sprint = project.sprints.find_by_id(element_id)
                  link = link_to_sprint(sprint) unless sprint.nil?
                when "product-backlog"
                  sprint = project.product_backlog
                  link = link_to_sprint(sprint) unless sprint.nil?
              end
            end
            (leading + (link || "#{project_identifier}#{element_type}#{separator}#{element_id_text}"))
          end
          return result
        end
        alias_method_chain :parse_redmine_links, :scrum

      end
    end
  end
end
