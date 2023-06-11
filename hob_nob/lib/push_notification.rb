require 'rubygems'
require 'aws-sdk'
require 'fcm'
module PushNotification
  
  
  def self.push_notification(notification, objekts, mobile_application_id)
    if notification.present? and objekts.present?
      notification.update_column(:pushed, true)
      # notification.create_notification_in_analytic
      notification.update_column(:push_datetime,Time.now + notification.event_timezone_offset.to_i.seconds)
      if objekts.present?
        arr = objekts.map{|invitee| {invitee_id:invitee.id,notification_id:notification.id,event_id:notification.event_id}}
        InviteeNotification.create(arr)
        push_pem_file = PushPemFile.where(:mobile_application_id => mobile_application_id).last
        event = notification.event
        title = (push_pem_file.title.present? ? push_pem_file.title : (event.marketing_app.blank? ? event.event_name : event.mobile_application.name))
        objekts.each do |objekt|
          begin
            b_count = objekt.get_badge_count
            devices = objekt.devices.where(mobile_application_id: mobile_application_id).where.not(enabled: 'false')
            push_to_devices(devices, notification, push_pem_file, title, b_count)
          rescue
          end
        end
      end
    end
  end

  def self.push_to_devices(devices, notification, push_pem_file, title, b_count=1)
    mobile_application = notification.event.mobile_application
    fcm_obj = FCM.new(push_pem_file.android_push_key)
    msg = notification.description
    ios_tokens = devices.where(platform: 'ios').pluck(:token)
    android_tokens = devices.where(platform: 'android').pluck(:token)
    data = {
      page: (notification.push_page rescue 'home'),
      page_id: 0,
      title: title,
      event_id: notification.event_id,
      image_url: notification.image.url,
      type: (notification.group_ids.present? ? notification.group_ids : 'All'),
      created_at: notification.push_datetime,
      notification_id: notification.id,
      formatted_push_datetime_with_event_timezone: notification.formatted_push_datetime_with_event_timezone,
      actionable_id: notification.actionable_id.to_s,
      push_type: 'fcm',
      action: 'Read',
      content_available: true,
      badge: b_count,
      sound: 'siren.aiff'
    }
    options = { data: data.merge(message: msg) }

    { android_push_response: android_tokens, ios_push_response: ios_tokens }.each do |response_type, tokens|
      options.merge!(notification: data.merge(body: msg)) if response_type == :ios_push_response
      response = fcm_obj.send(tokens, options)
      puts "******************************#{response}*************#{response_type} of fcm***************************************"
      Rails.logger.info("******************************#{response}***************#{response_type} of fcm*************************************")
    end
  end
end
