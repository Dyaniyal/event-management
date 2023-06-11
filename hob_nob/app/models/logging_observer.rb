class LoggingObserver < ActiveRecord::Observer
  observe Client, Event, Speaker, Attendee, Agenda, Invitee, Role, User, Poll, Feedback, Qna, Sponsor, Theme, Winner, Award, Comment, Conversation, EventFeature, Faq, Image, Like, Rating, HighlightImage,Favorite, Quiz,UserQuiz,Exhibitor, Notification, InviteeNotification, MyTravel, Campaign, UserRegistration, Analytic, SmtpSetting, Grouping, StoreInfo, StoreScreenshot, EKit, PushPemFile, EventGroup, Import, InviteeDatum, InviteeStructure, InviteeGroup, Panel, FeedbackForm,QnaSetting, Contact,QnaSetting # TelecallerAccessibleColumn,Edm, EdmMailSent

  def after_validation(record)
    if record.errors.present?
      logging_changes(record, 'validation_errors')
    end
  end

  def after_create(record)
    logging_changes(record, 'create')
  end

  def after_update(record)
    logging_changes(record, 'update')
  end

  def after_destroy(record)
    logging_changes(record, 'destroy')
  end

  def logging_changes(record, action)
    user_id = User.current.id rescue nil
    if action == 'validation_errors'
      attrs = record.attributes
      attrs[:messages] = record.errors.messages
      LogChange.create(:changed_data => attrs, :resourse_type => record.class.name, :resourse_id => record.id, :user_id => user_id, :action => action)
    elsif (record.class.name == "Invitee" and User.current.present?)
      LogChange.create(:changed_data => record.changed_attributes, :resourse_type => record.class.name, :resourse_id => record.id, :user_id => user_id, :email => record.email, :user_email => User.current.email, :event_id => record.event_id, :client_id => Event.find(record.event_id).client_id, :licensee_id => Event.find(record.event_id).client.licensee_id, :action => action)
    elsif ["InviteeDatum"].include? record.class.name
      email = User.current.email rescue ''
      LogChange.create(:changed_data => attrs, :resourse_type => record.class.name, :resourse_id => record.id, :user_id => user_id, :email => record.attr1, :user_email => email, :event_id => record.invitee_structure.event_id, :client_id => record.invitee_structure.event.client_id, :licensee_id =>record.invitee_structure.event.client.licensee_id, :action => action)
    elsif ["EventFeature","Agenda","Speaker","EKit","Poll","Quiz","FeedbackForm"].include? record.class.name and record.send(get_visiblity_column_name(record.class.name)) == "group"
      invitees = record.event.invitees.pluck(:id)
      invitee_ids = InviteeGroup.where("id in (?)",record.group_ids).map{|x| x.get_invitee_ids}.flatten
      invitees_log_ids = invitees - invitee_ids.map{|x| x.to_i}
      invitee_ids.each do |invitee|
        LogChange.create(:changed_data => record.changed_attributes, :resourse_type => record.class.name, :resourse_id => record.id, :user_id => invitee, :user_email => User.current.email, :event_id => record.event_id, :client_id => record.event.client_id, :action => action)
      end
    elsif ["Speaker", "Attendee", "Agenda", "Poll", "Feedback", "Qna", "Sponsor", "Winner", "Award", "Conversation", "EventFeature", "Faq", "HighlightImage", "Favorite", "Quiz", "UserQuiz", "Exhibitor", "Notification", "InviteeNotification", "MyTravel", "Campaign", "UserRegistration", "Analytic", "SmtpSetting", "Grouping", "EKit", "InviteeDatum", "InviteeStructure", "InviteeGroup", "Panel", "FeedbackForm", "QnaSetting", "Contact", "QnaSetting"].include? record.class.name and User.current.present?
      licensee_id = Event.find(record.event_id).client.licensee_id rescue ''
      client_id = Event.find(record.event_id).client_id rescue ''
      email = record.email_field_value if record.class.name == "UserRegistration" rescue ''
      LogChange.create(:changed_data => record.changed_attributes, :resourse_type => record.class.name, :resourse_id => record.id, :user_id => user_id, :user_email => User.current.email, email: email, :event_id => record.event_id, :client_id => client_id, :licensee_id => licensee_id, :action => action)
    else
      LogChange.create(:changed_data => record.changed_attributes, :resourse_type => record.class.name, :resourse_id => record.id, :user_id => user_id, :action => action)
    end
  end
end
