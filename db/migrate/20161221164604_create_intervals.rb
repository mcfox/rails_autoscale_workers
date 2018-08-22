class CreateIntervals < ActiveRecord::Migration[5.0]
  def change
    create_table :intervals do |t|
      t.references :cycle, foreign_key: true
      t.integer :position, default: 0
      t.integer :jobs, default: 0
      t.integer :slice_jobs, default: 0
      t.integer :workers, default: 0
      t.timestamps
    end
  end
end
