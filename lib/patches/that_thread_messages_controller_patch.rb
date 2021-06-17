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
                show_without_replies
                if Setting.plugin_that_thread['display'] == 'buttons'
                    ActiveRecord::Associations::Preloader.new.preload(@replies, [ { :reply_to => :replies }, :replies ])
                end
            end

        end

    end
end
