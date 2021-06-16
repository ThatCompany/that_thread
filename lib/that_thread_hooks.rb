class ThatThreadHook  < Redmine::Hook::ViewListener

    def view_layouts_base_html_head(context = {})
        stylesheet_link_tag('threads', :plugin => 'that_thread')
    end

    render_on :view_issues_show_details_bottom, partial: 'issues/thread'
    render_on :view_issues_edit_notes_bottom, :partial => 'issues/reply_to'

    render_on :view_my_account_preferences, :partial => 'users/reverse_order_note'
    render_on :view_users_form_preferences, :partial => 'users/reverse_order_note'

end
