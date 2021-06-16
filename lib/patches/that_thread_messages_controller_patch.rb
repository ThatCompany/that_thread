require_dependency 'messages_controller'

module Patches
    module ThatThreadMessagesControllerPatch

        def self.included(base)
            base.send(:include, InstanceMethods)
            base.class_eval do
                unloadable

                alias_method :show_without_replies, :show
                alias_method :show, :show_with_replies
            end
        end

        module InstanceMethods

            def show_with_replies
                if Setting.plugin_that_thread['display'] == 'thread'
                    @reply_count = @topic.children.count
                    @replies = @topic.children.includes(:author, :attachments, { :board => :project })
                                     .reorder("#{Message.table_name}.created_on ASC, #{Message.table_name}.id ASC").to_a
                    @replies = reoder_messages_for_thread_view(@replies)
                    @reply = Message.new(:subject => "RE: #{@message.subject}")

                    render :action => 'show', :layout => false if request.xhr?
                else
                    show_without_replies

                    if Setting.plugin_that_thread['display'] == 'buttons'
                        ActiveRecord::Associations::Preloader.new.preload(@replies, [ { :reply_to => :replies }, :replies ])
                    end
                end
            end

        private

            def reoder_messages_for_thread_view(messages)
                id_to_object_map = {}
                reodered_messages = []
                message_by_original_map = {}
                messages.each do |message|
                    id_to_object_map[message.id] = message
                    message.singleton_class.instance_eval{ attr_accessor :level }

                    if message.reply?
                        message_by_original_map[message.reply_to_id] ||= []
                        message_by_original_map[message.reply_to_id] << message
                        if original = id_to_object_map[message.reply_to_id]
                            message.level = (original.level || 0) + 1
                        end
                    else
                        reodered_messages << message
                    end
                end
                reodered_messages.each_with_index do |message, index|
                    if message_by_original_map[message.id]
                        reodered_messages[index + 1, 0] = message_by_original_map[message.id]
                    end
                end
            end

        end

    end
end
