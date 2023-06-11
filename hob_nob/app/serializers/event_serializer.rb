class EventSerializer < ActiveModel::Serializer

  def attributes
    data = super
  	data["id"] = object.id
    data["client_name"] = object.client_name
    data["business_unit"] = object.business_unit
    data["event_code"] = object.event_code
    data["event_name"] = object.event_name
    data["event_type"] = object.event_type
    data["multi_city"] = object.multi_city
    data["cities"] = object.cities
    data["start_event_date"] = object.start_event_date
    data["end_event_date"] = object.end_event_date
    data["start_event_time"] = object.start_event_time
    data["end_event_time"] = object.end_event_time
    data["venues"] = object.venues
    data["pax"] = object.pax
    data["event_admin_field"] = object.event_admin_field
    data["event_manager_field"] = object.event_manager_field
    data["event_executive_field"] = object.event_executive_field
    data["client_id"] = object.client_id
    data["created_at"] = object.created_at
    data["updated_at"] = object.updated_at
    data["theme_id"] = object.theme_id
    data["logo_file_name"] = object.logo_file_name
    data["description"] = object.description
  	data["display_type"] = object.display_type
    data["about"] = object.about
    data["status"] = object.status
    data["login_at"] = object.login_at
    data["rsvp"] = object.rsvp
    data["rsvp_message"] = object.rsvp_message
    data["countdown_ticker"] = object.countdown_ticker
    data["event_category"] = object.event_category
    data["set_activity_feed_as_homepage"] = object.set_activity_feed_as_homepage
    data["show_social_feeds"] = object.show_social_feeds
    data["marketing_app"] = object.marketing_app
    data["homepage_feature_name"] = object.homepage_feature_name
    data["primary_language"] = object.primary_language
    data["mult_lng_events"] = object.mult_lng_events
    data["parent_id"] = object.parent_id

    data["footer_image_url"] = object.footer_image_url
    data["display_time_zone"] = object.display_time_zone
    data["event_start_time_in_utc"] = object.event_start_time_in_utc
    data["about_date"] = object.about_date
  	data["inside_logo_url"] = object.inside_logo_url
    data["logo_url"] = object.logo_url
    Hash[*data.map{|k, v| v.nil? ? [k, v || ""] : [k, v]}.flatten]
  end
end
