class AddDefaultStatusToAgendasRatingStatus < ActiveRecord::Migration
  def up
    change_column_default :agendas, :rating_status, "active"
  end

  def down
    change_column_default :agendas, :rating_status, nil
  end
end
