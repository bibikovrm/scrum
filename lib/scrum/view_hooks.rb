module Scrum
  class ViewHooks < Redmine::Hook::ViewListener

    render_on(:view_issues_show_details_bottom, :partial => "scrum_hooks/issues/show")
    render_on(:view_issues_form_details_bottom, :partial => "scrum_hooks/issues/form")

  end
end
