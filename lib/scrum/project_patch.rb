require_dependency "project"

module Scrum
  module ProjectPatch
    def self.included(base)
      base.class_eval do

        has_many :sprints, :dependent => :destroy, :order => "start_date ASC, name ASC"
        belongs_to :product_backlog, :class_name => "Sprint"

      end
    end
  end
end
