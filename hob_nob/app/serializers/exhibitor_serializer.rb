class ExhibitorSerializer < ActiveModel::Serializer
  
  def attributes 
    data = super
    data[:id] = object.id
    data[:exhibitor_type] = object.exhibitor_type
    data[:name] = object.name
    data[:email] = object.email
    data[:description] = object.description
    data[:website_url] = object.website_url
    data[:image_url] = object.image_url
    data[:sequence] = object.sequence
    data[:mobile] = object.mobile
    data[:contact_person_name] = object.contact_person_name
    data[:event_id] = object.event_id
    Hash[*data.map{|k, v| v.nil? ? [k, v || ""] : [k, v]}.flatten]
  end
end
