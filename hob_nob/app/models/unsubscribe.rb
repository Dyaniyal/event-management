class Unsubscribe < ActiveRecord::Base

  validates :email,
            presence:true,
            format: {
              with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
              message: "This field is required."
            }

  scope :unsub_emails, -> (event) { where(unsubscribe: "true", event_id: event.id).pluck(:email) }

  def update_unsubscribe(status)
  	self.update_column(:unsubscribe, status)
  	self.check_and_update_opt_for_unsubscribe
  end

  def check_and_update_opt_for_unsubscribe
  	if self.unsubscribe == "true"
  	  event = Event.find(self.event_id)
  	  if event.invitee_structures.first.present?
  	  	invitee_structure  = event.invitee_structures.first
  	    invitee_datum = invitee_structure.invitee_datum.where(:attr1 => self.email).first if invitee_structure.present?
  	  end
  	  if invitee_datum.present?
  	    invitee_datum.update_column(:opt_unsubscribe, true)
  	  end
  	end
  end
end
