class AddJournalsReplyToId < Rails::VERSION::MAJOR < 5 ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]

    def self.up
        add_column :journals, :reply_to_id, :integer
    end

    def self.down
        remove_column :journals, :reply_to_id
    end

end
