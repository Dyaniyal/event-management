class AddLastForceDestroyedToModels < ActiveRecord::Migration
  def change
  	add_column :speakers, :last_force_destroyed, :datetime
  	add_column :agendas, :last_force_destroyed, :datetime
  	add_column :polls, :last_force_destroyed, :datetime
  	add_column :feedbacks, :last_force_destroyed, :datetime
  	add_column :qnas, :last_force_destroyed, :datetime
  	add_column :sponsors, :last_force_destroyed, :datetime
  	add_column :themes, :last_force_destroyed, :datetime
  	add_column :awards, :last_force_destroyed, :datetime
  	add_column :event_features, :last_force_destroyed, :datetime
  	add_column :faqs, :last_force_destroyed, :datetime
  	add_column :quizzes, :last_force_destroyed, :datetime
  	add_column :feedback_forms, :last_force_destroyed, :datetime
  	add_column :exhibitors, :last_force_destroyed, :datetime	
  end
end
