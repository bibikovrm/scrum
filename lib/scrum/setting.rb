module Scrum
  class Setting

    def self.create_journal_on_pbi_position_change
      setting_or_default(:create_journal_on_pbi_position_change) == "1"
    end

    def self.doer_color
      setting_or_default(:doer_color)
    end

    def self.reviewer_color
      setting_or_default(:reviewer_color)
    end

    def self.story_points_custom_field_id
      ::Setting.plugin_scrum[:story_points_custom_field_id]
    end

    def self.task_status_ids
      collect_ids(:task_status_ids)
    end

    def self.task_tracker_ids
      collect_ids(:task_tracker_ids)
    end

    def self.task_tracker
      Tracker.all(task_tracker_ids)
    end

    def self.pbi_tracker_ids
      collect_ids(:pbi_tracker_ids)
    end

    def self.verification_activity_ids
      collect_ids(:verification_activity_ids)
    end

    def self.tracker_id_color(id)
      setting_or_default("tracker_#{id}_color")
    end

    def self.inherit_pbi_attributes
      setting_or_default(:inherit_pbi_attributes) == "1"
    end

    def self.render_position_on_pbi
      setting_or_default(:render_position_on_pbi) == "1"
    end

    def self.render_category_on_pbi
      setting_or_default(:render_category_on_pbi) == "1"
    end

    def self.render_version_on_pbi
      setting_or_default(:render_version_on_pbi) == "1"
    end

    def self.render_author_on_pbi
      setting_or_default(:render_author_on_pbi) == "1"
    end

    def self.render_updated_on_pbi
      setting_or_default(:render_updated_on_pbi) == "1"
    end

    def self.tracker_fields(tracker)
      collect("tracker_#{tracker}_fields")
    end

    def self.tracker_field?(tracker, field)
      tracker_fields(tracker).include?(field.to_s)
    end

    def self.tracker_custom_fields(tracker)
      collect_ids("tracker_#{tracker}_custom_fields")
    end

    def self.tracker_custom_field?(tracker, custom_field)
      tracker_custom_fields(tracker).include?(custom_field.id)
    end

  private

    def self.setting_or_default(setting)
      ::Setting.plugin_scrum[setting] ||
      Redmine::Plugin::registered_plugins[:scrum].settings[:default][setting]
    end

    def self.collect_ids(setting)
      (::Setting.plugin_scrum[setting] || []).collect{|value| value.to_i}
    end

    def self.collect(setting)
      (::Setting.plugin_scrum[setting] || [])
    end

  end
end
