class AddDescriptionToQnaSettings < ActiveRecord::Migration
  def change
    add_column :qna_settings, :description, :text
  end
end
