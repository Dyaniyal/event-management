class AddColumnToMobileConsentQuestions < ActiveRecord::Migration
  def change
  	add_column :mobile_consent_questions, :mandate_question , :boolean , :default => false
  end
end
