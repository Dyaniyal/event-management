class AddConsentLinksToEdm < ActiveRecord::Migration
  def change
    add_column :edms, :consent_links, :string
  end
end
