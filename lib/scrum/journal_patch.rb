# Copyright © Emilio González Montaña
# Licence: Attribution & no derivates
#   * Attribution to the plugin web page URL should be done if you want to use it.
#     https://redmine.ociotec.com/projects/redmine-plugin-scrum
#   * No derivates of this plugin (or partial) are allowed.
# Take a look to licence.txt file at plugin root folder for further details.

require_dependency "journal"

module Scrum
  module JournalPatch
    # Prepended to ensure compatibility with other plugins
    def self.prepended(base)
      base.class_eval do
      end

    private

      def add_attribute_detail(attribute, old_value, value)
        # Do not check setting if attribute is not position
        if (attribute != 'position') || Scrum::Setting.create_journal_on_pbi_position_change
          super(attribute, old_value, value)
        end
      end
    end
  end
end
