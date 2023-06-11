class CreateJoinTableClientUser < ActiveRecord::Migration
  def change
    create_join_table :clients, :users do |t|
      # t.index [:client_id, :user_id]
      # t.index [:user_id, :client_id]
    end
  end
end
