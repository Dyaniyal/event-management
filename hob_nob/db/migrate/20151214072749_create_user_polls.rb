class CreateUserPolls < ActiveRecord::Migration
  def change
    create_table :user_polls do |t|
      t.references :user, index: true
      t.references :poll, index: true
      t.string      :answer
      t.timestamps null: false
    end
  end
end
