module ScrumHelper

  def render_story_points_units(story_points, options = {})
    if story_points.nil?
      ""
    else
      render :inline => "<span title=\"#{options[:title]}\">" +
                          "#{l(:label_story_point_unit, story_points.to_i)}" +
                        "</span>"
    end
  end

  def render_story_points(story_points, options = {})
    if story_points.nil?
      ""
    else
      if story_points.is_a?(Integer)
        text = ("%d" % story_points) unless options[:ignore_zero] and story_points == 0
      elsif story_points.is_a?(Float)
        text = ("%g" % story_points) unless options[:ignore_zero] and story_points == 0.0
      else
        text = story_points unless options[:ignore_zero] and (story_points.blank? or (story_points == "0"))
      end
      if text.blank?
        ""
      else
        text = "<span title=\"#{options[:title]}\">#{text}"
        text += "</span>"
        text += " #{render_story_points_units(story_points)}" unless options[:no_units]
        render :inline => text
      end
    end
  end

  def render_hours(hours, options = {})
    if hours.nil?
      ""
    else
      if hours.is_a?(Integer)
        text = ("%d" % hours) unless options[:ignore_zero] and hours == 0
      elsif hours.is_a?(Float)
        text = ("%g" % hours) unless options[:ignore_zero] and hours == 0.0
      else
        text = hours unless options[:ignore_zero] and (hours.blank? or (hours == "0"))
      end
      render :inline => "<span title=\"#{options[:title]}\">" +
                          "#{text}h" +
                        "</span>" unless text.blank?
    end
  end

end
