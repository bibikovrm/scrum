# Copyright © Emilio González Montaña
# Licence: Attribution & no derivates
#   * Attribution to the plugin web page URL should be done if you want to use it.
#     https://redmine.ociotec.com/projects/redmine-plugin-scrum
#   * No derivates of this plugin (or partial) are allowed.
# Take a look to licence.txt file at plugin root folder for further details.

require_dependency 'issue_query'

module Scrum
  module IssueQueryPatch
    def self.prepended(base)
      base.class_eval do

        # Transparent Overload
        self.available_columns << QueryColumn.new(:sprint,
                                                  :sortable => lambda {Sprint.fields_for_order_statement},
                                                  :groupable => true)
        # Transparent Overload
        self.available_columns << QueryColumn.new(:position,
                                                  :sortable => "#{Issue.table_name}.position")
      end

      # Method pre-pended => no need to alias
      def initialize_available_filters
        filters = super
        if project
          sprints = project.sprints_and_product_backlogs
          if sprints.any?
            add_available_filter 'sprint_id',
                                 :type => :list_optional,
                                 :values => sprints.sort.collect{|s| [s.name, s.id.to_s]}
            add_available_filter 'position',
                                 :type => :integer
            add_associations_custom_fields_filters :sprint
          end
        end
        filters
      end

      # Method pre-pended => no need to alias, => transparent Overload
      def issues(options = {})
        options[:include] ||= []
        options[:include] << :sprint
        super(options)
      end

      # Method pre-pended => no need to alias, => transparent Overload
      def issue_ids(options = {})
        options[:include] ||= []
        options[:include] << :sprint
        super(options)
      end

      # Method pre-pended => no need to alias, => transparent Overload
      def available_columns()
        if !@available_columns
          @available_columns = super
          index = nil
          @available_columns.each_with_index {|column, i| index = i if column.name == :estimated_hours}
          index = (index ? index + 1 : -1)
          # insert the column after estimated_hours or at the end
          @available_columns.insert index, QueryColumn.new(:pending_effort,
            :sortable => "COALESCE((SELECT effort FROM #{PendingEffort.table_name} WHERE #{PendingEffort.table_name}.issue_id = #{Issue.table_name}.id ORDER BY #{PendingEffort.table_name}.date DESC LIMIT 1), 0)",
            :default_order => 'desc'
          )
        end
        return @available_columns
      end
    end
  end
end
