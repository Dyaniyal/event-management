class AddNewCategoryToFaqs < ActiveRecord::Migration
  def change
    add_column :faqs, :new_category, :string
  end
end
