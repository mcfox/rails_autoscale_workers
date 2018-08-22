class LoginSecurity < ActiveRecord::Migration[4.2]
  def up
    ## Security
    add_column :users, :unique_session_id, :string, limit: 20 unless column_exists? :users, :unique_session_id

    unless column_exists? :users, :password_changed_at
      add_column :users, :password_changed_at, :datetime
      add_index :users, :password_changed_at
    end
    unless column_exists? :users, :last_activity_at
      add_column :users, :last_activity_at, :datetime
      add_index :users, :last_activity_at
    end
    unless column_exists? :users, :expired_at
      add_column :users, :expired_at, :datetime
      add_index :users, :expired_at
    end
    unless column_exists? :users, :paranoid_verification_code
      add_column :users, :paranoid_verification_code, :string
      add_index :users, :paranoid_verification_code
    end
    add_column :users, :paranoid_verification_attempt, :integer, default: 0 unless column_exists? :users, :paranoid_verification_attempt
    unless column_exists? :users, :paranoid_verified_at
      add_column :users, :paranoid_verified_at, :datetime
      add_index :users, :paranoid_verified_at
    end

    unless table_exists?(:old_passwords)
      create_table :old_passwords do |t|
        t.timestamps null: false
        t.string :encrypted_password, null: false
        t.string :password_archivable_type, null: false
        t.integer :password_archivable_id, null: false
        t.string :password_salt # Optional. bcrypt stores the salt in the encrypted password field so this column may not be necessary.
        t.datetime :created_at
      end
      add_index :old_passwords, [:password_archivable_type, :password_archivable_id], name: :index_password_archivable
    end

    create_table :security_questions do |t|
      t.string :locale, null: false
      t.string :name, null: false
    end

    add_column :users, :security_question_id, :integer unless column_exists? :users, :security_question_id
    add_column :users, :security_question_answer, :string unless column_exists? :users, :security_question_answer
  end

  # #Remove All
  def down
    if table_exists?(:users)
      change_table :users do |t|
        t.remove :unique_session_id, :password_changed_at, :last_activity_at, :expired_at, :paranoid_verification_code,
                 :paranoid_verification_attempt
      end
    end
    drop_table :old_passwords if table_exists?(:old_passwords)
    drop_table :security_questions if table_exists?(:security_questions)
  end

end

