class AddSponsorIdToAgendas < ActiveRecord::Migration
  def change
    add_column :agendas, :sponsor_id, :integer
  end
end
