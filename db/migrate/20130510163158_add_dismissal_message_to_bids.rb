class AddDismissalMessageToBids < ActiveRecord::Migration
  def change
    add_column :bids, :dismissal_message, :text
    add_column :bids, :show_dismissal_message_to_vendor, :boolean, default: false
  end
end
