class MyTravelSerializer < ActiveModel::Serializer
  
  def attributes 
  	data = super
  	data[:id] = object.id
  	data[:invitee_id] = object.invitee_id
  	data[:event_id] = object.event_id
  	data[:attach_file_1_name] = object.attach_file_1_name
  	data[:attach_file_2_name] = object.attach_file_2_name
  	data[:attach_file_3_name] = object.attach_file_3_name
  	data[:attach_file_4_name] = object.attach_file_4_name
  	data[:attach_file_5_name] = object.attach_file_5_name
  	data[:attached_url_1] = object.attached_url_1
  	data[:attached_url_2] = object.attached_url_2
  	data[:attached_url_3] = object.attached_url_3
  	data[:attached_url_4] = object.attached_url_4
  	data[:attached_url_5] = object.attached_url_5
  	data[:attachment_type] = object.attachment_type
  	data[:comment_box] = object.comment_box
  	Hash[*data.map{|k, v| v.nil? ? [k, v || ""] : [k, v]}.flatten]
  end
end
