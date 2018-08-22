class CreateCycles < ActiveRecord::Migration[5.0]
  def change
    create_table :cycles do |t|
      t.references :work_manager, foreign_key: true
      t.integer :queue_jobs, default: 0
      t.integer :new_jobs, default: 0
      t.integer :processed_jobs, default: 0
      t.integer :workers, default: 0
      t.integer :desired_workers, default: 0
      t.timestamps
    end
  end
end
