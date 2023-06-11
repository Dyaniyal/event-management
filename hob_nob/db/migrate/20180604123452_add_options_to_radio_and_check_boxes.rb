class AddOptionsToRadioAndCheckBoxes < ActiveRecord::Migration
  def change
  	1.upto(10) do |i|
  	  add_column :consent_questions, :"option_#{i}", :text
  	end
  end
end
