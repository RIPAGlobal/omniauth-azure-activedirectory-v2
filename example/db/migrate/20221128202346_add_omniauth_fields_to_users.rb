class AddOmniauthFieldsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :provider, :string
    add_column :users, :uid, :string
  end
end
