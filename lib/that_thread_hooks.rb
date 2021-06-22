class ThatThreadHook  < Redmine::Hook::ViewListener

    def view_layouts_base_html_head(context = {})
        stylesheet_link_tag('threads', :plugin => 'that_thread')
    end

    def view_issues_history_journal_bottom(context = {})
        if Setting.plugin_that_thread['display'] == 'thread' && !User.current.wants_comments_in_reverse_order?
            context[:hook_caller].javascript_tag("$('#change-#{context[:journal].id}')[0].style.setProperty('--indice', #{context[:journal].indice});")
        end
    end

    render_on :view_issues_show_details_bottom, partial: 'issues/thread'
    render_on :view_issues_edit_notes_bottom, :partial => 'issues/reply_to'

    render_on :view_my_account_preferences, :partial => 'users/reverse_order_note'
    render_on :view_users_form_preferences, :partial => 'users/reverse_order_note'

end
