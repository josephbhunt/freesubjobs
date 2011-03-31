class CreateAssignments < ActiveRecord::Migration
  def self.up
    create_table :assignments do |t|
      t.string :teacher
      t.string :school
      t.string :subject
      t.string :room
      t.string :phone_number
      t.string :date
      t.string :time
      t.string :duration
      t.string :start_time
      t.string :end_time
      t.integer :job_id
      t.timestamps
    end
  end

  def self.down
    drop_table :assignments
  end
end
