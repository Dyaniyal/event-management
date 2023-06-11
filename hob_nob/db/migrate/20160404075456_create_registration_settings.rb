class CreateRegistrationSettings < ActiveRecord::Migration
  def change
    create_table :registration_settings do |t|
    	t.string :external_reg
      t.text :reg_url
      t.text :reg_surl
      t.string :external_login
      t.text :login_url
      t.text :login_surl
      t.text :forget_pass_url
      t.text :forget_pass_surl


      t.timestamps null: false
    end
  end
end
