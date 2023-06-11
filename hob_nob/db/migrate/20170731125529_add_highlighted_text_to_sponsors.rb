class AddHighlightedTextToSponsors < ActiveRecord::Migration
  def change
    add_column :sponsors, :highlighted_text, :text
  end
end
