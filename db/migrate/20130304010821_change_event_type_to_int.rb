class ChangeEventTypeToInt < ActiveRecord::Migration
  def up
    remove_column :events, :event_type
    add_column :events, :event_type, :smallint
  end

  def down
    remove_column :events, :event_type
    add_column :events, :event_type, :string
  end
end
