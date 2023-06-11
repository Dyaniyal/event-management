class AddLoginButtonAndTextColorToMobileApplication < ActiveRecord::Migration
  def change
  	add_column :mobile_applications, :login_button_color, :string
  	add_column :mobile_applications, :login_button_text_color, :string
  end
end
