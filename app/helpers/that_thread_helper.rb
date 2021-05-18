module ThatThreadHelper

    def render_issue_thread_quotes(journal, no_html = false)
        if Setting.plugin_that_thread['email_quotes'] && journal.reply?
            render :partial => 'issue_quote', :formats => [ no_html ? :text : :html ], :locals => { :journal => journal.reply_to, :level => 1 }
        end
    end

    def render_message_thread_quotes(message, no_html = false)
        if Setting.plugin_that_thread['email_quotes'] && message.reply?
            render :partial => 'message_quote', :formats => [ no_html ? :text : :html ], :locals => { :message => message.reply_to, :level => 1 }
        end
    end

end
