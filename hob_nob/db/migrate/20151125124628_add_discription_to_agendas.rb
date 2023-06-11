class AddDiscriptionToAgendas < ActiveRecord::Migration
  def change
    add_column :agendas, :discription, :text
  end
end
