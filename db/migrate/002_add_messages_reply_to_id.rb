class AddMessagesReplyToId < Rails::VERSION::MAJOR < 5 ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]

    def self.up
        add_column :messages, :reply_to_id, :integer
    end

    def self.down
        remove_column :messages, :reply_to_id
    end

end
