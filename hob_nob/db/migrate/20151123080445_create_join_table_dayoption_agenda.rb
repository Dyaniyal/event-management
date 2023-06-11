class CreateJoinTableDayoptionAgenda < ActiveRecord::Migration
  def change
    create_join_table :dayoptions, :agendas do |t|
      # t.index [:dayoption_id, :agenda_id]
      # t.index [:agenda_id, :dayoption_id]
    end
  end
end
