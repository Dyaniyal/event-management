class AddHighlightLanguageUpdatedToEvents < ActiveRecord::Migration
  def change
    add_column :events, :highlight_language_updated, :boolean
  end
end
