require_dependency 'attachments_helper'

module Patches
    module ThatThreadAttachmentsHelperPatch

        def self.included(base)
            base.send(:include, InstanceMethods)
            base.class_eval do
                unloadable

                alias_method :link_to_attachments_without_reply, :link_to_attachments
                alias_method :link_to_attachments, :link_to_attachments_with_reply

                define_method :message_navigation_link, instance_method(:message_navigation_link)
                define_method :topic_top_siblings,      instance_method(:topic_top_siblings)
            end
        end

        module InstanceMethods

            # Hack: we use link_to_attachments to add Reply links to forum messages
            def link_to_attachments_with_reply(container, options = {})
                content = link_to_attachments_without_reply(container, options)

                if container.is_a?(Message) && container.root != container && !container.root.locked? && authorize_for('messages', 'reply')
                    thread_links = link_to(l(:button_reply), '#', :onclick => "$('#message_reply_to_id').val(#{container.id}); $('#reply').show(); $('#message_content').focus(); return false;")
                    if Setting.plugin_that_thread['display'] == 'buttons'
                        siblings = container.reply? ? container.reply_to.replies.map(&:id) : topic_top_siblings(container)
                        indice = siblings.find_index(container.id)
                        nav_links = message_navigation_link(l(:label_in_response_to), container, container.reply_to_id, :class => 'icon-thread-up') + ' &middot; '.html_safe
                        nav_links << message_navigation_link(l(:label_previous), container, indice && indice > 0 && siblings[indice - 1], :class => 'icon-thread-previous') + ' &middot; '.html_safe
                        nav_links << message_navigation_link(l(:label_response), container, container.replies.first.try(&:id), :class => 'icon-thread-down') + ' &middot; '.html_safe
                        nav_links << message_navigation_link(l(:label_next), container, indice && siblings[indice + 1], :class => 'icon-thread-next')
                        thread_links << content_tag('span', nav_links, :class => 'navigation-links')
                    end
                    content = content_tag('div', thread_links, :class => 'thread-links') + (content || '')
                end

                content
            end

        private

            def topic_top_siblings(message)
                @top_siblings ||= message.root.children.where(:reply_to_id => nil).pluck(:id)
            end

            def message_navigation_link(label, container, message_id, options = {})
                link_options = {}
                link_options[:class] = 'icon-only'
                link_options[:class] << ' ' + options[:class] if options[:class]
                if message_id
                    link_options[:title] = label
                    link_options[:class] << ' active'
                else
                    link_options[:onclick] = 'return false;'
                end
                link_to(label, message_id ? board_message_path(container.board, container.parent, :r => message_id, :anchor => "message-#{message_id}") : '#', link_options)
            end

        end

    end
end
