require_dependency 'journal'

module Patches
    module ThatThreadJournalPatch

        def self.included(base)
            base.send(:include, InstanceMethods)
            base.class_eval do
                unloadable

                belongs_to :reply_to, :class_name => 'Journal'
                has_many :replies, :class_name => 'Journal', :foreign_key => 'reply_to_id'

                attr_accessor :html_data

                before_create :handle_invalid_reply

                alias_method :css_classes_without_thread, :css_classes
                alias_method :css_classes, :css_classes_with_thread
            end
        end

        module InstanceMethods

            def reply?
                !!reply_to
            end

            def css_classes_with_thread
                css_classes = css_classes_without_thread
                if html_data && html_data[:level] && html_data[:level] > 0
                    css_classes << " idnt idnt-#{html_data[:level] > 9 ? 9 : html_data[:level]}"
                end
                css_classes
            end

        private

            def handle_invalid_reply
                self.reply_to_id = nil if reply_to_id? && (!reply_to || notes.blank? || journalized != reply_to.journalized)
            end

        end

    end
end
