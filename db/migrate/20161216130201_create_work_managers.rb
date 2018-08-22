class CreateWorkManagers < ActiveRecord::Migration[5.0]
  def change
    create_table :work_managers do |t|
      t.string :name
      t.string :aws_region
      t.string :autoscalinggroup_name
      t.string :queue_name
      t.integer :max_workers
      t.integer :min_workers
      t.integer :minutes_to_process
      t.integer :jobs_per_cycle
      t.integer :minutes_between_cycles
      t.boolean :active, default: true
      t.datetime :last_check
      t.string :last_error, null: true, limit: 500
      t.references :application, foreign_key: true
      t.timestamps
    end
  end
end
