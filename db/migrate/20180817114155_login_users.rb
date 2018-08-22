class LoginUsers < ActiveRecord::Migration[4.2]
  def up
    unless table_exists?(:users)
      create_table :users do |t|
        t.timestamps null: false
      end
    end
    add_column :users, :name, :string, null: false, default: '' unless column_exists? :users, :name
    add_column :users, :email, :string, null: false, default: '' unless column_exists? :users, :email
    add_column :users, :encrypted_password, :string, null: true, default: '' unless column_exists? :users, :encrypted_password

    ## Recoverable
    add_column :users, :reset_password_token, :string unless column_exists? :users, :reset_password_token
    add_column :users, :reset_password_sent_at, :datetime unless column_exists? :users, :reset_password_sent_at

    ## Rememberable
    add_column :users, :remember_created_at, :datetime unless column_exists? :users, :remember_created_at

    ## Trackable
    add_column :users, :sign_in_count, :integer, default: 0, null: false unless column_exists? :users, :sign_in_count
    add_column :users, :current_sign_in_at, :datetime unless column_exists? :users, :current_sign_in_at
    add_column :users, :last_sign_in_at, :datetime unless column_exists? :users, :last_sign_in_at
    add_column :users, :current_sign_in_ip, :string unless column_exists? :users, :current_sign_in_ip
    add_column :users, :last_sign_in_ip, :string unless column_exists? :users, :last_sign_in_ip

    ## Confirmable
    add_column :users, :confirmation_token, :string unless column_exists? :users, :confirmation_token
    add_column :users, :confirmed_at, :datetime unless column_exists? :users, :confirmed_at
    add_column :users, :confirmation_sent_at, :datetime unless column_exists? :users, :confirmation_sent_at
    add_column :users, :unconfirmed_email, :string unless column_exists? :users, :unconfirmed_email # Only if using reconfirmable

    ## Lockable
    add_column :users, :failed_attempts, :integer, null: false, default: 0 unless column_exists? :users, :failed_attempts
    add_column :users, :unlock_token, :string unless column_exists? :users, :unlock_token
    add_column :users, :locked_at, :datetime unless column_exists? :users, :locked_at

    ## Invitable
    add_column :users, :invitation_token, :string unless column_exists? :users, :invitation_token
    add_column :users, :invitation_created_at, :datetime unless column_exists? :users, :invitation_created_at
    add_column :users, :invitation_sent_at, :datetime unless column_exists? :users, :invitation_sent_at
    add_column :users, :invitation_accepted_at, :datetime unless column_exists? :users, :invitation_accepted_at
    add_column :users, :invitation_limit, :integer unless column_exists? :users, :invitation_limit
    unless column_exists? :users, :invited_by_id
      add_column :users, :invited_by_id, :integer, foreign_key: false
      add_column :users, :invited_by_type, :string
      add_index :users, [:invited_by_id, :invited_by_type]
    end
    unless column_exists? :users, :invitations_count
      add_column :users, :invitations_count, :integer, default: 0
      add_index :users, :invitations_count
    end

    # Token authenticatable (For manual implementations in the application)
    add_column :users, :authentication_token, :string unless column_exists? :users, :authentication_token

    #Omniauth
    add_column :users, :provider, :string unless column_exists? :users, :provider
    add_column :users, :uid, :string unless column_exists? :users, :uid
  end

  # #Remove All
  def down
    if table_exists?(:users)
      change_table :users do |t|
        t.remove_references :invited_by, :polymorphic => true
        t.remove :reset_password_token, :reset_password_sent_at, :remember_created_at, :sign_in_count,
                 :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip, :last_sign_in_ip, :authentication_token #, :email, :encrypted_password
        t.remove :invitations_count, :invitation_limit, :invitation_sent_at, :invitation_accepted_at, :invitation_token,
                 :invitation_created_at
      end
      change_column_null :users, :encrypted_password, false
    end
  end
end
