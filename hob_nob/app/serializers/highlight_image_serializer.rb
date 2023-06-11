class HighlightImageSerializer < ActiveModel::Serializer
  
  def attributes 
  	data = super
  	data[:id] = object.id
  	data[:name] = object.name
  	data[:event_id] = object.event_id
  	data[:highlight_image_url] = object.highlight_image_url
    Hash[*data.map{|k, v| v.nil? ? [k, v || ""] : [k, v]}.flatten]
	end
end
