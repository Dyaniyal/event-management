class Chat < ActiveRecord::Base
  require 'rubygems'
  require 'aws-sdk'
  require 'push_notification'
  require 'fcm'
  attr_accessor :platform

  belongs_to :event
  validates :chat_type, :sender_id,:member_ids,presence: { :message => "This field is required." }
  before_create :set_parent_id_multilingual
  after_create :set_date_time, :set_event_timezone
  after_create :send_puch_notification, :create_analytic_record, :update_last_updated_model

  def set_parent_id_multilingual
    if self.event.present? and self.event.parent_id.present?
      self.event_id = self.event.parent_id
    end
  end  
  
  def update_last_updated_model
    LastUpdatedModel.update_record(self.class.name)
  end

  def get_sender_name(id)
    Invitee.find_by_id(id).name_of_the_invitee rescue ""
  end

  def get_member_name(ids)
    names = ""
    names = Invitee.where("id IN(?)",ids.split(",")).map {|i| i.name_of_the_invitee} rescue ""
    names.join(",")
  end

  def set_date_time
    self.update_column(:date_time, Time.now)
  end

  def set_event_timezone
    event = self.event
    self.update_column("event_timezone", event.timezone)
    self.update_column("event_timezone_offset", event.timezone_offset)
    self.update_column("event_display_time_zone", event.display_time_zone)
  end

  def send_puch_notification
    receivers = Invitee.where(id: member_ids.split(',').map{|a| a.to_i}) rescue nil
    mobile_application = event.mobile_application rescue nil
    push_pem_file = mobile_application.push_pem_file rescue nil
    send_to_receivers(receivers, mobile_application, push_pem_file) if sender_id.present? && receivers.present? && push_pem_file.present?
  end

  def send_to_receivers(receivers, mobile_application, push_pem_file)
    sender = Invitee.find_by_id(sender_id)
    if sender
      receivers.each do |receiver|
        b_count = receiver.get_badge_count
        devices = receiver.devices.where(mobile_application_id: mobile_application.id).where.not(enabled: 'false')
        title = (event.marketing_app ? mobile_application.name : event.event_name)
        Rails.logger.info("***********#{devices.pluck(:platform)}*******************#{devices.pluck(:token)}***************#{devices.pluck(:email)}*************************************")
        Chat.push_to_devices(devices, message, push_pem_file, b_count, 'chat', 0, sender, member_ids, event_id, title)
      end
    end
  end

  def self.push_to_devices(devices, msg, push_pem_file, b_count=1, push_page='', page_id='', sender, member_ids, event_id, title)
    event = Event.find(event_id)
    mobile_application = event.mobile_application
    fcm_obj = FCM.new(push_pem_file.android_push_key)
    ios_tokens = devices.where(platform: 'ios').pluck(:token)
    android_tokens = devices.where(platform: 'android').pluck(:token)
    data = {
      page: push_page,
      page_id: 0,
      badge: b_count,
      sound: "siren.aiff",
      title: title,
      sender_id: sender.id,
      sender_name: sender.get_invitee_name,
      message_text: msg,
      member_ids: member_ids,
      event_id: event_id,
      time: Time.now.strftime('%d/%m/%Y %H:%M')
    }
    options = { data: data.merge(message: msg) }

    { android_push_response: android_tokens, ios_push_response: ios_tokens }.each do |response_type, tokens|
      options.merge!(notification: data.merge(body: "#{sender.get_invitee_name}: #{msg}")) if response_type == :ios_push_response
      response = fcm_obj.send(tokens, options)
      Rails.logger.info("******************************#{response}***************#{response_type} of fcm *************************************")
    end
  end

  def create_analytic_record
    if Analytic.where('viewable_type = ? and action = ? and invitee_id = ? and event_id = ? and Date(created_at) = ?', "Chat", self.chat_type, self.sender_id, self.event_id, Date.today).blank?
      analytic = Analytic.new(viewable_type: "Chat", viewable_id: self.id, action: self.chat_type, invitee_id: self.sender_id, event_id: self.event_id, platform: self.platform)
      analytic.save rescue nil
    end
  end

  def created_at_with_event_timezone
    # self.created_at.in_time_zone(self.event_timezone)
    self.created_at + self.event_timezone_offset.to_i.seconds
  end

  def updated_at_with_event_timezone
    # self.updated_at.in_time_zone(self.event_timezone)
    self.updated_at + self.event_timezone_offset.to_i.seconds
  end

end