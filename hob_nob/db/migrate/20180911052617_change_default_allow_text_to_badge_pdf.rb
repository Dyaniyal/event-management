class ChangeDefaultAllowTextToBadgePdf < ActiveRecord::Migration
  def change
    change_column_default :badge_pdfs, :allow_text, "yes"
  end
end
