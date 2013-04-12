class CreateGlobalConfigs < ActiveRecord::Migration
  def change
    create_table :global_configs do |t|
      t.boolean :bid_review_enabled, default: true
      t.boolean :bid_submission_enabled, default: true
      t.boolean :comments_enabled, default: true
      t.boolean :questions_enabled, default: true
      t.text :event_hooks

      t.timestamps
    end
  end
end
