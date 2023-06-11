class AddRatingStatusToAgendas < ActiveRecord::Migration
  def change
    add_column :agendas, :rating_status, :string
  end
end
