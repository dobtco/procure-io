class AddTargetableToEvents < ActiveRecord::Migration
  def change
    add_column :events, :targetable_type, :string
    add_column :events, :targetable_id, :integer
  end
end
