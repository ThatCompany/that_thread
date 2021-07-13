require_dependency 'mail_handler'

module Patches
    module ThatThreadMailHandlerPatch

        def self.included(base)
            base.send(:include, InstanceMethods)
            base.class_eval do
                unloadable

                alias_method :receive_issue_reply_without_reply_to, :receive_issue_reply
                alias_method :receive_issue_reply, :receive_issue_reply_with_reply_to

                alias_method :receive_message_reply_without_reply_to, :receive_message_reply
                alias_method :receive_message_reply, :receive_message_reply_with_reply_to

                alias_method :issue_attributes_from_keywords_without_reply_to, :issue_attributes_from_keywords
                alias_method :issue_attributes_from_keywords, :issue_attributes_from_keywords_with_reply_to

                alias_method :cleaned_up_subject_without_reply_to, :cleaned_up_subject
                alias_method :cleaned_up_subject, :cleaned_up_subject_with_reply_to
            end
        end

        module InstanceMethods

        private

            def receive_issue_reply_with_reply_to(issue_id, from_journal = nil)
                @from_journal = from_journal
                receive_issue_reply_without_reply_to(issue_id, from_journal)
            end

            def receive_message_reply_with_reply_to(message_id)
                @from_message_id = message_id
                receive_message_reply_without_reply_to(message_id)
            end

            def issue_attributes_from_keywords_with_reply_to(issue)
                attrs = issue_attributes_from_keywords_without_reply_to(issue)
                attrs['reply_to_id'] = @from_journal.id if @from_journal && @from_journal.notes?
                attrs
            end

            def cleaned_up_subject_with_reply_to
                subject = cleaned_up_subject_without_reply_to
                # A hack, see ThatThreadMessagePatch
                subject << "\nre##{@from_message_id}" if @from_message_id
                subject
            end

        end

    end
end
