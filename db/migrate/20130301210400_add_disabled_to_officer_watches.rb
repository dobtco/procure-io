class AddDisabledToOfficerWatches < ActiveRecord::Migration
  def change
    add_column :officer_watches, :disabled, :boolean, default: false
  end
end
