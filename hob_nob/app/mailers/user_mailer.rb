class UserMailer < ActionMailer::Base
  # default from: 'contact@ascratech.com'

  # before_filter :set_credential
  # before_filter :set_from_email
  #VALID_EMAIL_REGEX = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  add_template_helper(Admin::EdmsHelper)

  def welcome_email(sender, licensee)
    @smtp_setting = sender.get_licensee_admin.smtp_setting
    if @smtp_setting.present?
      set_credential(@smtp_setting)
      @licensee = licensee
      mail(to: 'gopikrishna@ascratech.in', subject: 'Welcome to My Awesome Site', from: @smtp_setting.from_email)
    end  
  end

  def send_mail_to_new_invitee(invitee)
    @invitee = invitee
    mail(to: @invitee.email, subject: 'You have been invitted for event')
  end

  def send_event_mail_to_licensee(store_info)
    @mobile_application = MobileApplication.find(store_info.mobile_application_id)
    @licensee = @mobile_application.client.licensee
    mail(from: "info@hobnobspace.com", to: "info@hobnobspace.com", bcc: "minakshi@ascratech.com,mitesh@ascratech.in", subject: "Your #{@mobile_application.name} created")
  end

  def send_password_invitees(invitee,event)
    @smtp_setting = event.smtp_setting.present? ? event.smtp_setting : invitee.get_licensee_admin.smtp_setting
    if @smtp_setting.present?
      set_credential(@smtp_setting)
      @invitee = invitee
      @event = @invitee.event
      @mobile_application = @event.mobile_application
      mail(to: invitee.email, subject: "Your #{@mobile_application.name} App Credentials", from: @smtp_setting.from_email, :bcc => "gopikrishna@ascratech.in")
    end  
  end
  def forgot_password_invitees(invitee,event)
    @smtp_setting = event.smtp_setting.present? ? event.smtp_setting : invitee.get_licensee_admin.smtp_setting
    if @smtp_setting.present?
      set_credential(@smtp_setting)
      @invitee = invitee
      @event = @invitee.event
      @mobile_application = @event.mobile_application
      mail(to: invitee.email, subject: "Your #{@mobile_application.name} App Credentials", from: @smtp_setting.from_email, :bcc => "gopikrishna@ascratech.in")
    end  
  end
  

  def default_template(edm,email,smtp_setting,user_registration = nil,database_data = nil,database_email_field= nil)
    set_credential(smtp_setting)
    @campaign = edm.campaign
    #@event = @campaign.events.first
    @event = Event.find_by_id(edm.event_id)
    @smtp_setting = smtp_setting
    @edm = edm
    @email = email
    @user_registration = user_registration
    @db_data = database_data
    @database_email_field = database_email_field
    #valid = @email  =~ VALID_EMAIL_REGEX
    if true#valid == 0
      mail(to: email,from: (@smtp_setting.from_email.present? ? (@edm.present? and @edm.sender_name.present?) ? "#{@edm.sender_name} <#{@smtp_setting.from_email}>": @smtp_setting.from_email : "info@hobnobspace.com"), :bcc => @edm.bcc,:cc => @edm.cc, subject: @edm.subject_line,:reply_to => @edm.reply_to_email) 
    end  
    # mail(to: email,from: (@edm.from_email.present? ? @edm.from_email : "info@hobnobspace.com"), :bcc => "shiv@ascratech.com",subject: @edm.subject_line) 
  end
  
 def custom_template(edm,email,smtp_setting,user_registration= nil,database_data = nil,database_email_field= nil)
    set_credential(smtp_setting)
    @smtp_setting = smtp_setting
    @campaign = edm.campaign
    @edm = edm
    @db_data = database_data
    @database_email_field = database_email_field
    @email = email
    @user_registration = user_registration
    @event = Event.find_by_id(@edm.event_id)
    #valid = @email  =~ VALID_EMAIL_REGEX
    if true#valid == 0
      mail(to: email,from: (@smtp_setting.from_email.present? ? (@edm.present? and @edm.sender_name.present?) ? "#{@edm.sender_name} <#{@smtp_setting.from_email}>": @smtp_setting.from_email : "info@hobnobspace.com"), :bcc => @edm.bcc,:cc => @edm.cc, subject: @edm.subject_line,:reply_to => @edm.reply_to_email) 
    end
    # mail(to: email,from: (@edm.sender_email.present? ? @edm.from_email : "info@hobnobspace.com"), :bcc => "shiv@ascratech.in",subject: @edm.subject_line)
  end

  def send_mail_to_receiver(receiver,sender,event)
    # @smtp_setting = sender.get_licensee_admin.smtp_setting
    @smtp_setting = event.smtp_setting.present? ? event.smtp_setting : sender.get_licensee_admin.smtp_setting
    if @smtp_setting.present?
      set_credential(@smtp_setting)
      @receiver = receiver
      @event = @receiver.event
      @sender = sender
      mail(to: receiver.speaker_email, subject: "#{sender.name_of_the_invitee} has asked you a question", from: @smtp_setting.from_email, :bcc => "gopikrishna@ascratech.in")
    end  
  end

  private

  def set_credential(smtp_setting)
    hsh = {:user_name => smtp_setting.username, :password => smtp_setting.password, :domain => smtp_setting.domain, :address => smtp_setting.address, :port => 587, :authentication => :plain, :enable_starttls_auto => true, :openssl_verify_mode  => 'none'}
    ActionMailer::Base.smtp_settings.merge!(hsh)
  end

end
