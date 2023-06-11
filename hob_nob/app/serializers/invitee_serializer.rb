class InviteeSerializer < ActiveModel::Serializer
  
  def attributes 
  	data = super
    data[:id] = object.id
  	data[:first_name] = object.first_name
  	data[:last_name] = object.last_name
  	data[:designation] = object.designation
  	data[:event_name] = object.event_name
  	data[:name_of_the_invitee] = object.name_of_the_invitee
  	data[:email] = object.email
  	data[:company_name] = object.company_name
  	data[:event_id] = object.event_id
  	data[:about] = object.about
  	data[:interested_topics] = object.interested_topics
  	data[:country] = object.country
  	data[:mobile_no] = object.mobile_no
		data[:website] = object.website
		data[:street] = object.street
		data[:locality] = object.locality
		data[:location] = object.location
		data[:invitee_status] = object.invitee_status
		data[:provider] = object.provider
		data[:linkedin_id] = object.linkedin_id
		data[:google_id] = object.google_id
		data[:twitter_id] = object.twitter_id
		data[:facebook_id] = object.facebook_id
		data[:instagram_id] = object.instagram_id
		data[:points] = object.points
		data[:created_at] = object.created_at
		data[:updated_at] = object.updated_at
		data[:profile_pic_updated_at] = object.profile_pic_updated_at
		data[:qr_code_updated_at] = object.qr_code_updated_at
		data[:qr_code_url] = object.qr_code_url
		data[:profile_pic_url] = object.profile_pic_url
		data[:rank] = object.rank
		data[:feedback_last_updated_at] = object.feedback_last_updated_at
    Hash[*data.map{|k, v| v.nil? ? [k, v || ""] : [k, v]}.flatten]
  end
end
