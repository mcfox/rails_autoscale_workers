class BusinessHours < ActiveRecord::Migration[5.2]
  def change
    add_column :work_managers, :min_workers_off, :integer, default: 0
    add_column :work_managers, :max_workers_off, :integer, default: 1
    add_column :work_managers, :description, :string
  end
end
