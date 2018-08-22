class CreateApplications < ActiveRecord::Migration[5.0]
  def change
    create_table :applications do |t|
      t.string :name
      t.string :aws_access_key_id
      t.string :aws_secret_access_key
      t.boolean :valid_aws_credentials, default: false
      t.string :jobs_url
      t.boolean :valid_jobs_url, default: false
      t.boolean :active, default: true
      t.timestamps
    end
  end
end
