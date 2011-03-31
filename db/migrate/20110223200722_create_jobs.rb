class CreateJobs < ActiveRecord::Migration
  def self.up
    create_table :jobs do |t|
      t.string :hcc
      t.string :notes
      t.string :absr_id
      t.integer :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :jobs
  end
end
