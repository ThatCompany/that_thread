require_dependency 'issue'

module Patches
    module ThatThreadIssuePatch

        def self.included(base)
            base.extend(ClassMethods)
            base.send(:include, InstanceMethods)
            base.class_eval do
                unloadable

                delegate :reply_to, :reply_to=, :reply_to_id, :reply_to_id=, :to => :current_journal, :allow_nil => true

                safe_attributes :reply_to_id, :if => lambda { |issue, user| issue.notes_addable?(user) }

                alias_method :visible_journals_with_index_without_replies, :visible_journals_with_index
                alias_method :visible_journals_with_index, :visible_journals_with_index_with_replies
            end
        end

        module ClassMethods

            def load_journals_thread_data(journals)
                id_to_object_map = {}
                last_reply_id = nil
                journals.each do |journal|
                    next unless journal.is_a?(Journal)
                    break if journal.html_data # Already processed
                    id_to_object_map[journal.id] = journal
                    journal.html_data = {}

                    if journal.reply? && (original = id_to_object_map[journal.reply_to_id])
                        journal.html_data[:reply_to] = original.indice
                        original.html_data[:reply] = journal.indice unless original.html_data[:reply]
                        if original.html_data[:last_reply_id] && (last_reply = id_to_object_map[original.html_data[:last_reply_id]])
                            journal.html_data[:previous] = last_reply.indice
                            last_reply.html_data[:next] = journal.indice
                        end
                        original.html_data[:last_reply_id] = journal.id
                    elsif journal.notes?
                        if last_reply_id && (last_reply = id_to_object_map[last_reply_id])
                            journal.html_data[:previous] = last_reply.indice
                            last_reply.html_data[:next] = journal.indice
                        end
                        last_reply_id = journal.id
                    end
                end
            end

            def reoder_journals_for_thread_view(journals)
                id_to_object_map = {}
                reodered_journals = []
                journal_by_original_map = {}
                journals.each do |journal|
                    id_to_object_map[journal.id] = journal
                    journal.html_data = {}

                    if journal.reply?
                        journal_by_original_map[journal.reply_to_id] ||= []
                        journal_by_original_map[journal.reply_to_id] << journal
                        if original = id_to_object_map[journal.reply_to_id]
                            journal.html_data[:level] = (original.html_data[:level] || 0) + 1
                        end
                    else
                        journal.html_data[:level] = 0
                        reodered_journals << journal
                    end
                end
                reodered_journals.each_with_index do |journal, index|
                    if journal_by_original_map[journal.id]
                        reodered_journals[index + 1, 0] = journal_by_original_map[journal.id]
                    end
                end
            end

        end

        module InstanceMethods

            def visible_journals_with_index_with_replies(user = User.current)
                visible_journals = visible_journals_with_index_without_replies(user)

                if Setting.plugin_that_thread['display'] == 'buttons'
                    self.class.load_journals_thread_data(visible_journals)
                end

                visible_journals
            end

        end

    end
end
