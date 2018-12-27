class SaveWorkset < ActiveRecord::Migration[5.2]
  def change
    add_column :work_managers, :workset_array, :text
  end
end
