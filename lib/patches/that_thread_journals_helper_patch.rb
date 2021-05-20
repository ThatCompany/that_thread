require_dependency 'journals_helper'

module Patches
    module ThatThreadJournalsHelperPatch

        def self.included(base)
            base.send(:include, InstanceMethods)
            base.class_eval do
                unloadable

                alias_method :render_notes_without_reply, :render_notes
                alias_method :render_notes, :render_notes_with_reply

                define_method :render_navigation_link, instance_method(:render_navigation_link)
                define_method :notes_anchor_prefix,    instance_method(:notes_anchor_prefix)
            end
        end

        module InstanceMethods

            def render_notes_with_reply(issue, journal, options = {})
                content = render_notes_without_reply(issue, journal, options)

                if options[:reply_links] && !request.xhr?
                    reply_handler = "$('#issue_reply_to_id').val(#{journal.id});"
                    reply_handler << "$('#update .edit_issue .box > fieldset.tabular').hide();" if Redmine::Plugin.installed?(:that_issue_reply_button)
                    reply_handler << "showAndScrollTo('update', 'issue_notes'); return false;"
                    thread_links = link_to(l(:button_reply), edit_issue_path(issue, :issue => { :reply_to_id => journal.id }), :onclick => reply_handler)
                    if Setting.plugin_that_thread['display'] == 'buttons' && journal.html_data
                        reverse = User.current.wants_comments_in_reverse_order?
                        nav_links = render_navigation_link(l(:label_in_response_to), journal.html_data[:reply_to], :class => reverse ? 'icon-thread-down' : 'icon-thread-up') + ' &middot; '.html_safe
                        nav_links << render_navigation_link(l(:label_previous), journal.html_data[:previous], :class => 'icon-thread-previous') + ' &middot; '.html_safe
                        nav_links << render_navigation_link(l(:label_response), journal.html_data[:reply], :class => reverse ? 'icon-thread-up' : 'icon-thread-down') + ' &middot; '.html_safe
                        nav_links << render_navigation_link(l(:label_next), journal.html_data[:next], :class => 'icon-thread-next')
                        thread_links << content_tag('span', nav_links, :class => 'navigation-links')
                    end
                    content << content_tag('div', thread_links, :class => 'thread-links')
                end

                content
            end

        private

            def render_navigation_link(label, indice, options = {})
                link_options = {}
                link_options[:class] = 'icon-only'
                link_options[:class] << ' ' + options[:class] if options[:class]
                if indice
                    link_options[:title] = "#{label}: ##{indice}"
                    link_options[:class] << ' active'
                else
                    link_options[:onclick] = 'return false;'
                end
                link_to(label, indice ? "##{notes_anchor_prefix}-#{indice}" : '#', link_options)
            end

            def notes_anchor_prefix
                @anchor_prefix ||= Redmine::VERSION::MAJOR < 4 && Redmine::Plugin.installed?(:redmine_issue_tabs) ? 'notes' : 'note'
            end

        end

    end
end
