class AddAskAnQuestionToAgendas < ActiveRecord::Migration
  def change
    add_column :agendas, :ask_an_question, :string
  end
end
