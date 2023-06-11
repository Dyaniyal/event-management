class AddLicenseeLogoToUsers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.attachment :licensee_logo
    end
  end

  def self.down
    remove_attachment :users, :licensee_logo
  end
end
