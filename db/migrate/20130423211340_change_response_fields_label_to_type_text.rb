class ChangeResponseFieldsLabelToTypeText < ActiveRecord::Migration
  def up
    change_column :response_fields, :label, :text
  end

  def down
    change_column :response_fields, :label, :string
  end
end
