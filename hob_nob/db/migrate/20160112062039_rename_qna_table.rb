class RenameQnaTable < ActiveRecord::Migration
  def change
    rename_table :ques_answers, :qnas
  end
end
