class ThatThreadHook  < Redmine::Hook::ViewListener

    def view_layouts_base_html_head(context = {})
        stylesheet_link_tag('threads', :plugin => 'that_thread')
    end

    render_on :view_issues_edit_notes_bottom, :partial => 'issues/reply_to'

end
