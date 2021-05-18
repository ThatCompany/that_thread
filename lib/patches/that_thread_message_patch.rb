require_dependency 'message'

module Patches
    module ThatThreadMessagePatch

        def self.included(base)
            base.send(:include, InstanceMethods)
            base.class_eval do
                unloadable

                belongs_to :reply_to, :class_name => 'Message'
                has_many :replies, :class_name => 'Message', :foreign_key => 'reply_to_id'

                before_create :handle_invalid_reply

                safe_attributes :reply_to_id
            end
        end

        module InstanceMethods

            def subject=(value)
                # A hack to assign reply_to_id before notifications are sent
                if value.is_a?(String) && value =~ %r{\nre#(\d+)\z}
                    self.reply_to_id = $1
                    value.gsub!(%r{\nre#\d+\z}, '')
                end
                write_attribute(:subject, value)
            end

            def reply?
                !!reply_to
            end

        private

            def handle_invalid_reply
                self.reply_to_id = nil if reply_to_id? && (!reply_to || self == root || reply_to == root || root != reply_to.root)
            end

        end

    end
end
