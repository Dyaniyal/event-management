class SpeakerSerializer < ActiveModel::Serializer
  
  def attributes 
  	data = super
    data[:id] = object.id
  	data[:event_name] = object.event_name
  	data[:speaker_name] = object.speaker_name
  	data[:designation] = object.designation
  	data[:email_address] = object.email_address
  	data[:address] = object.address
  	data[:speaker_info] = object.speaker_info
  	data[:rating] = object.rating
  	data[:feedback] = object.feedback
  	data[:event_id] = object.event_id
  	data[:created_at] = object.created_at
  	data[:updated_at] = object.updated_at
		data[:phone_no] = object.phone_no
		data[:company] = object.company
		data[:is_answerable] = object.is_answerable
		data[:is_rated] = object.is_rated
		data[:sequence] = object.sequence
		data[:rating_status] = object.rating_status
		data[:first_name] = object.first_name
		data[:last_name] = object.last_name
		data[:all_agenda_ids] = object.all_agenda_ids
		data[:profile_pic_updated_at] = object.profile_pic_updated_at
		data[:twitter_id] = object.twitter_id
		data[:facebook_id] = object.facebook_id
		data[:google_id] = object.google_id
		data[:linkedin_id] = object.linkedin_id
		data[:profile_pic_url] = object.profile_pic_url
    Hash[*data.map{|k, v| v.nil? ? [k, v || ""] : [k, v]}.flatten]
  end
end
