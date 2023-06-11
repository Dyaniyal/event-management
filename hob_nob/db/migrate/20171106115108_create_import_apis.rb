class CreateImportApis < ActiveRecord::Migration
  def change
    create_table :import_apis do |t|
      t.text :username
      t.text :password
      t.text :tablename
      t.text :pagenumber
			t.integer :user_id
			      
      t.timestamps null: false
    end
  end
end
