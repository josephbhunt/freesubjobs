class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :email
      t.string :aesop_id
      t.string :user_agent
      t.string :guid
      t.string :session_id
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
