class InviteeNotificationSerializer < ActiveModel::Serializer
  
  def attributes 
    data = super
  	data[:id] = object.id
  	data[:event_id] = object.event_id
  	data[:invitee_id] = object.invitee_id
  	data[:notification_id] = object.notification_id
  	data[:open] = object.open
  	data[:unread] = object.unread
    Hash[*data.map{|k, v| v.nil? ? [k, v || ""] : [k, v]}.flatten]
  end
end
