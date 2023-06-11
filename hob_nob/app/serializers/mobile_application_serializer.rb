class MobileApplicationSerializer < ActiveModel::Serializer
  def attributes 
  	data = super
    data[:id] = object.id
    data[:name] = object.name
    data[:application_type] = object.application_type
    data[:client_id] = object.client_id
    data[:id] = object.id
    data[:login_background_color] = object.login_background_color
    data[:message_above_login_page] = object.message_above_login_page
    data[:registration_message] = object.registration_message
    data[:registration_link] = object.registration_link
    data[:login_button_color] = object.login_button_color
    data[:login_button_text_color] = object.login_button_text_color
    data[:listing_screen_text_color] = object.listing_screen_text_color
    data[:social_media_status] = object.social_media_status
    data[:login_background_updated_at] = object.login_background_updated_at
    data[:listing_screen_background_updated_at] = object.listing_screen_background_updated_at
    data[:visitor_registration] = object.visitor_registration
    data[:social_media_logins] = object.social_media_logins
    data[:app_icon_updated_at] = object.app_icon_updated_at
    data[:splash_screen_updated_at] = object.splash_screen_updated_at
    data[:all_events_listing] = object.all_events_listing
    data[:agreeing_terms_and_conditions] = object.agreeing_terms_and_conditions
    data[:user_agreement_text] = object.user_agreement_text
    data[:url_1_text] = object.url_1_text
    data[:url_1_link] = object.url_1_link
    data[:url_2_text] = object.url_2_text
    data[:url_2_link] = object.url_2_link
    data[:visitor_registration_back_color] = object.visitor_registration_back_color
    data[:marketing_app_event_id] = object.marketing_app_event_id
    data[:data_visible] = object.data_visible
    data[:app_icon_url] = object.app_icon_url
    data[:splash_screen_url] = object.splash_screen_url
    data[:login_background_url] = object.login_background_url
    data[:listing_screen_background_url] = object.listing_screen_background_url
    data[:visitor_registration_background_image_url] = object.visitor_registration_background_image_url
    data[:multilingual_app] = object.multilingual_app
    Hash[*data.map{|k, v| v.nil? ? [k, v || ""] : [k, v]}.flatten]
  end
end
