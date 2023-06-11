class AddParamColumnsInCustomPages < ActiveRecord::Migration
  def change
  	for x in 1..10 do
  		for i in 1..5 do
	  		add_column "custom_page#{x}s", "param#{i}_name", :string
	  		add_column "custom_page#{x}s", "param#{i}_value", :string
	  	end
  	end
  end
end
