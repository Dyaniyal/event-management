class AddAboutLanguageUpdatedToEvents < ActiveRecord::Migration
  def change
    add_column :events, :about_language_updated, :boolean, :default => false
  end
end
