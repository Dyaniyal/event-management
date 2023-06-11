class InviteeNotification < ActiveRecord::Base
  attr_accessor :platform
  belongs_to :notification

  validates :invitee_id, :notification_id, :event_id, presence: { :message => "This field is required." }
  after_save :update_last_updated_model
  after_create :create_analytic_invitee_notification
  
  def update_last_updated_model
    LastUpdatedModel.update_record(self.class.name)
  end

  def create_analytic_invitee_notification
    notification = self.notification
  	if (notification.show_on_activity == true)
  		self.create_invitee_notification_in_analytic
  	end
  end

  def create_invitee_notification_in_analytic
    Analytic.create(:viewable_type => "InviteeNotification",:viewable_id => self.id,:action => "notification",:event_id => self.event_id, :invitee_id => self.invitee_id)
  end

end
