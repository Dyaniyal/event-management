class AddPhonenoToSpeakers < ActiveRecord::Migration
  def change
    add_column :speakers, :phone_no, :string
  end
end
