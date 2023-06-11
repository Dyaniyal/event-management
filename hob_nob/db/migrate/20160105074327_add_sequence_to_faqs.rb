class AddSequenceToFaqs < ActiveRecord::Migration
  def change
    add_column :faqs, :sequence, :float
  end
end
