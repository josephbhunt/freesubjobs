class CreateJobs < ActiveRecord::Migration
  def self.up
    create_table :jobs do |t|
      t.string :teacher
      t.string :school
      t.string :subject
      t.string :room
      t.string :phone_number
      t.string :date
      t.string :time
      t.string :duration
      t.string :notes
      t.string :absr_id
      t.text :details
      t.integer :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :jobs
  end
end
