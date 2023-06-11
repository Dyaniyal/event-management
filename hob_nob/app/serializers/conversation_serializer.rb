class ConversationSerializer < ActiveModel::Serializer
  attributes 

  def attributes
  	data = super
    data[:id] = object.id
    data[:description] = object.description
    data[:event_id] = object.event_id
    data[:user_id] = object.user_id
    data[:created_at] = object.created_at
    data[:updated_at] = object.updated_at
    data[:status] = object.status
    data[:action] = object.action
    data[:first_name_user] = object.first_name_user
    data[:last_name_user] = object.last_name_user
    data[:profile_pic_url_user] = object.profile_pic_url_user
    data[:last_update_comment_description] = object.last_update_comment_description
    data[:last_interaction_at] = object.last_interaction_at
    data[:actioner_id] = object.actioner_id
    data[:on_wall] = object.on_wall
    data[:event_timezone] = object.event_timezone
    data[:event_timezone_offset] = object.event_timezone_offset
    data[:event_display_time_zone] = object.event_display_time_zone
    data[:comments_count_cache] = object.comments_count_cache
    data[:likes_count_cache] = object.likes_count_cache
    data[:parent_id] = object.parent_id
    data[:multi_lng_parent_id] = object.multi_lng_parent_id
    data[:language_updated] = object.language_updated
    data[:image_url] = object.image_url
    data[:company_name] = object.company_name
    data[:like_count] = object.like_count
    data[:user_name] = object.user_name
    data[:comment_count] = object.comment_count
    data[:formatted_created_at_with_event_timezone] = object.formatted_created_at_with_event_timezone
    data[:formatted_updated_at_with_event_timezone] = object.formatted_updated_at_with_event_timezone
    data[:first_name] = object.first_name
    data[:last_name] = object.last_name
    data[:profile_pic_url] = object.profile_pic_url
    data[:share_count] = object.share_count
    Hash[*data.map{|k, v| v.nil? ? [k, v || ""] : [k, v]}.flatten]
  end
end

