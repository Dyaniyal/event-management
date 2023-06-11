class AddFeatureToAgendas < ActiveRecord::Migration
  def change
  	add_column :agendas, :show_agenda_feature, :string
    add_column :agendas, :group_ids, :text
  end
end
