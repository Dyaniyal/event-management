class SponsorSerializer < ActiveModel::Serializer
  
  def attributes 
  	data = super
  	data[:id] = object.id
  	data[:event_id] = object.event_id
  	data[:sponsor_type] = object.sponsor_type
  	data[:name] = object.name
  	data[:email] = object.email
  	data[:description] = object.description
  	data[:website_url] = object.website_url
  	data[:sequence] = object.sequence
  	data[:mobile] = object.mobile
  	data[:contact_person_name] = object.contact_person_name
  	data[:highlighted_text] = object.highlighted_text
  	data[:rating_status] = object.rating_status
	  data[:image_url] = object.image_url
  	Hash[*data.map{|k, v| v.nil? ? [k, v || ""] : [k, v]}.flatten]
  end
end
