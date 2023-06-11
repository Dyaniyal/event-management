class AddPortToSmtpSettings < ActiveRecord::Migration
  def change
    add_column :smtp_settings, :port, :string
  end
end
