class FavoriteSerializer < ActiveModel::Serializer
  
  def attributes 
    data = super
  	data[:id] = object.id
	  data[:invitee_id] = object.invitee_id
	  data[:favoritable_type] = object.favoritable_type
	  data[:favoritable_id] = object.favoritable_id
	  data[:event_id] = object.event_id
	  data[:status] = object.status
	  data[:image_url] = object.image_url
    Hash[*data.map{|k, v| v.nil? ? [k, v || ""] : [k, v]}.flatten]
  end
end
