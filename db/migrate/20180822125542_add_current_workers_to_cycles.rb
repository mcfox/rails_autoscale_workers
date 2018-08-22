class AddCurrentWorkersToCycles < ActiveRecord::Migration[5.2]
  def change
    add_column :cycles, :current_workers, :integer, default: 0
  end
end
