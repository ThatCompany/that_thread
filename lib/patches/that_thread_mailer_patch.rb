require_dependency 'mailer'

module Patches
    module ThatThreadMailerPatch

        def self.included(base)
            base.extend(FixedTokenForMethod) if Redmine::VERSION::MAJOR < 4 || Redmine::VERSION::MINOR < 1
            if Redmine::VERSION::MAJOR > 3
                base.send(:include, Redmine4InstanceMethods)
            else
                base.send(:include, Redmine3InstanceMethods)
            end
            base.send(:include, CommonInstanceMethods)
            base.class_eval do
                unloadable

                if Redmine::VERSION::MAJOR < 4 || Redmine::VERSION::MINOR < 1
                    class << self
                        alias_method :token_for_without_fixed_id, :token_for
                        alias_method :token_for, :token_for_with_fixed_id
                    end
                end

                alias_method :issue_edit_without_reply, :issue_edit
                alias_method :issue_edit, :issue_edit_with_reply

                alias_method :message_posted_without_reply, :message_posted
                alias_method :message_posted, :message_posted_with_reply
            end
        end

        module FixedTokenForMethod

            def token_for_with_fixed_id(object, rand = true)
                if Setting.plugin_that_thread['fix_message_id'] && [ Issue, Journal, Message ].include?(object.class)
                    hash = [
                        'redmine',
                        "#{object.class.name.demodulize.underscore}-#{object.id}",
                        object.created_on.utc.strftime('%Y%m%d%H%M%S'),
                        object.is_a?(Journal) ? object.user.id : object.author.id
                    ]
                    host = Setting.mail_from.to_s.strip.gsub(%r{^.*@|>}, '')
                    host = "#{::Socket.gethostname}.redmine" if host.empty?
                    "#{hash.join('.')}@#{host}"
                else
                    token_for_without_fixed_id(object, rand)
                end
            end

        end

        module Redmine4InstanceMethods

            def issue_edit_with_reply(user, journal)
                email = issue_edit_without_reply(user, journal)
                reply_headers(email, journal) if journal.reply?
                email
            end

            def message_posted_with_reply(user, message)
                email = message_posted_without_reply(user, message)
                reply_headers(email, message) if message.reply?
                email
            end

        end

        module Redmine3InstanceMethods

            def issue_edit_with_reply(journal, to_users, cc_users)
                email = issue_edit_without_reply(journal, to_users, cc_users)
                reply_headers(email, journal) if journal.reply?
                email
            end

            def message_posted_with_reply(message)
                email = message_posted_without_reply(message)
                reply_headers(email, message) if message.reply?
                email
            end

        end

        module CommonInstanceMethods

        private

            def reply_headers(message, object)
                return unless object.reply_to
                message[:in_reply_to] = if self.class.method(:message_id_for).arity == 2 # Redmine 4.1 and above
                    "<#{self.class.message_id_for(object.reply_to, object.reply_to.is_a?(Journal) ? object.reply_to.user : object.reply_to.author)}>"
                else
                    "<#{self.class.message_id_for(object.reply_to)}>"
                end
                references = []
                while object = object.reply_to
                    references << if self.class.method(:references_for).arity == 2 # Redmine 4.1 and above
                        "<#{self.class.references_for(object, object.is_a?(Journal) ? object.user : object.author)}>"
                    else
                        "<#{self.class.references_for(object)}>"
                    end
                end
                message[:references] = message[:references].to_s + ' ' + references.reverse.join(' ')
                message.subject.prepend('RE: ')
            end

        end

    end
end
