class CreateFeedbackForms < ActiveRecord::Migration
  def change
    create_table :feedback_forms do |t|
    	t.integer :sequence
    	t.text :title
    	t.integer :event_id

      t.timestamps null: false
    end
  end
end
