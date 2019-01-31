class ManagerHistory < ActiveRecord::Migration[5.2]
  def change
    add_column :work_managers, :history, :json
  end
end
