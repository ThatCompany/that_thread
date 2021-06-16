require 'redmine'

require_dependency 'that_thread_hooks'

Rails.logger.info 'Starting That Thread plugin for Redmine'

Rails.configuration.to_prepare do
    unless Mailer.included_modules.include?(ThatThreadHelper)
        Mailer.send(:helper, :that_thread)
        Mailer.send(:include, ThatThreadHelper)
    end

    unless MessagesController.included_modules.include?(Patches::ThatThreadMessagesControllerPatch)
        MessagesController.send(:include, Patches::ThatThreadMessagesControllerPatch)
    end
    unless JournalsController.included_modules.include?(Patches::ThatThreadJournalsControllerPatch)
        JournalsController.send(:include, Patches::ThatThreadJournalsControllerPatch)
    end
    unless JournalsHelper.included_modules.include?(Patches::ThatThreadJournalsHelperPatch)
        JournalsHelper.send(:include, Patches::ThatThreadJournalsHelperPatch)
    end
    unless AttachmentsHelper.included_modules.include?(Patches::ThatThreadAttachmentsHelperPatch)
        AttachmentsHelper.send(:include, Patches::ThatThreadAttachmentsHelperPatch)
    end
    unless Redmine::Pagination::Helper.included_modules.include?(Patches::ThatThreadPaginationHelperPatch)
        Redmine::Pagination::Helper.send(:include, Patches::ThatThreadPaginationHelperPatch)
    end
    unless MailHandler.included_modules.include?(Patches::ThatThreadMailHandlerPatch)
        MailHandler.send(:include, Patches::ThatThreadMailHandlerPatch)
    end
    unless Mailer.included_modules.include?(Patches::ThatThreadMailerPatch)
        Mailer.send(:include, Patches::ThatThreadMailerPatch)
    end
    unless Issue.included_modules.include?(Patches::ThatThreadIssuePatch)
        Issue.send(:include, Patches::ThatThreadIssuePatch)
    end
    unless Journal.included_modules.include?(Patches::ThatThreadJournalPatch)
        Journal.send(:include, Patches::ThatThreadJournalPatch)
    end
    unless Message.included_modules.include?(Patches::ThatThreadMessagePatch)
        Message.send(:include, Patches::ThatThreadMessagePatch)
    end
end

Redmine::Plugin.register :that_thread do
    name 'That Thread'
    author 'Andriy Lesyuk for That Company'
    author_url 'http://www.andriylesyuk.com/'
    description 'Enables threaded conversations for issue notes and forum messages.'
    url 'https://github.com/thatcompany/that_thread'
    version '0.0.1'

    settings :default => {
        'display'        => '',
        'fix_message_id' => false,
        'email_quotes'   => false
    }, :partial => 'settings/thread'
end
