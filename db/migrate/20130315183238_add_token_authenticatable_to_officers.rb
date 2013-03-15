class AddTokenAuthenticatableToOfficers < ActiveRecord::Migration
  def change
    add_column :officers, :authentication_token, :string
    add_index  :officers, :authentication_token, unique: true

  end
end
