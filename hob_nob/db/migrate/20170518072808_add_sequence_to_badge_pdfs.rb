class AddSequenceToBadgePdfs < ActiveRecord::Migration
  def change
    add_column :badge_pdfs, :sequence, :string
  end
end
