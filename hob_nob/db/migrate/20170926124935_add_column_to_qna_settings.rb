class AddColumnToQnaSettings < ActiveRecord::Migration
  def change
    add_column :qna_settings, :ask_a_question_to, :string, :limit => 20, :default => "Ask a question to "
  end
end
