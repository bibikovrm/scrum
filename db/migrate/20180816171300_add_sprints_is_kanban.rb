# Copyright © Emilio González Montaña
# Licence: Attribution & no derivatives
#   * Attribution to the plugin web page URL should be done if you want to use it.
#     https://redmine.ociotec.com/projects/redmine-plugin-scrum
#   * No derivatives of this plugin (or partial) are allowed.
# Take a look to licence.txt file at plugin root folder for further details.

class AddSprintsIsKanban < ActiveRecord::Migration
  def self.up
    add_column :sprints, :is_kanban, :boolean, :default => false
    add_index :sprints, [:is_kanban], :name => 'sprints_is_kanban'
  end

  def self.down
    remove_column :sprints, :is_kanban
  end
end
