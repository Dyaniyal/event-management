module CopyEvent

  FEATURES_WITHOUT_TABLES = ['galleries', 'event_highlights', 'feedbacks', 'venue', 'my_profile', 'content', 'engagement', 'qnas', 'database', 'registration', 'telecaller', 'communication', 'activity_feeds', 'maps', "agendas"] 
  All_FEATURES = ["awards","speakers", "sponsors", "agenda_tracks", "agendas",  "contacts", "conversation_wall", "custom_page1s", "custom_page2s", "custom_page3s", "custom_page4s", "custom_page5s", "custom_page6s", "custom_page7s", "custom_page8s", "custom_page9s", "custom_page10s", "e_kits", "emergency_exit", "event_features", "exhibitors", "feedback_forms","feedbacks", "faqs", "groupings", "highlight_images", "folders", "images", "invitee_structures", "map", "mobile_application", "my_profiles", "my_travels", "panels", "polls", "poll_wall", "quizzes", "quiz_wall", "qna_wall", "qna_settings", "registration_settings", "registrations", "registration_look_and_feels", "theme"]

  def self.copy(parent_event, features, is_multilingual)
    child_event = initilize_child_event(parent_event, is_multilingual)
    associations_to_clone = is_multilingual ? All_FEATURES : get_tables_to_clone(features, child_event)
    save_child_event(associations_to_clone, parent_event, child_event)
    child_event
  end

  def self.initilize_child_event(parent_event, is_multilingual)
    child_event = parent_event.dup
    child_event.event_name = "#{parent_event.event_name}"
    child_event.inside_logo = parent_event.inside_logo 
    child_event.logo = parent_event.logo
    child_event.footer_image = parent_event.footer_image
    child_event.skip_validation = true
    if is_multilingual
      child_event.parent_id = parent_event.id
      child_event.primary_language = nil
      parent_event.update_column('mult_lng_events',true)
    end
    child_event
  end
  
  def self.get_tables_to_clone(associations_to_clone, child_event)
    associations_without_tables = associations_to_clone & FEATURES_WITHOUT_TABLES
    associations_to_clone = associations_to_clone - FEATURES_WITHOUT_TABLES
    associations_without_tables.each do |feature_name|
      associations_to_clone.unshift(get_association_name(feature_name))
    end
    associations_to_clone.unshift("speakers") if associations_to_clone.include? "speakers"
    associations_to_clone = associations_to_clone.compact.flatten
    associations_to_clone = remove_not_required_data(associations_to_clone, child_event)
    associations_to_clone.uniq
  end

  def self.save_child_event(associations_to_clone, parent_event, child_event)
    if child_event.save
      child_event.add_default_invitee
      associations_to_clone.each do |table|
        copy_associations(parent_event.send(table), child_event, table)
      end
    end
  end

  def self.copy_associations(objekts, child_event, table)
    objekts = [objekts] unless objekts.is_a? ActiveRecord::Associations::CollectionProxy
    objekts.each do |objekt|
      copy_objekt(objekt, child_event, table) if objekt.present?
    end
  end

  def self.copy_objekt(objekt, child_event, table)
    new_objekt = objekt.dup 
    case 
      when table == 'mobile_application'
        new_objekt = (objekt.application_type == "multi event" or child_event.parent_id.present?) ? objekt : new_objekt
        new_objekt.parent_id = new_objekt.new_record? ? objekt.id : nil
        new_objekt.save(:validate => false)
        child_event.update_column('mobile_application_id',new_objekt.id)
      when table == 'theme'
        new_objekt.parent_id = objekt.id 
        new_objekt.save
        child_event.update_column('theme_id', new_objekt.id)
      when table == 'e_kits'
        new_objekt.event_id = child_event.id
        new_objekt.parent_id = objekt.id
        new_objekt.tag_list << objekt.tag_list
      when table == 'images'
        new_objekt.parent_id = objekt.id
        new_objekt.imageable_id = child_event.id
        if objekt.folder.present?
          new_folder = Folder.find_or_create_by(:event_id => child_event.id, :name => objekt.folder.name) 
        end
        new_objekt.folder_id = new_folder.present? ? new_folder.id : nil
      when table == 'invitees'
        new_objekt.event_id = child_event.id
        new_objekt.parent_id = objekt.id 
        new_objekt.points = 0
      else
        new_objekt.event_id = child_event.id
        new_objekt.parent_id = objekt.id
    end
    new_objekt.save(:validate => false)
    copy_objekt_association(objekt, new_objekt, child_event, table)  
  end
  
  def self.copy_objekt_association(objekt, new_objekt, child_event, table)
    if ["polls", "e_kits", "agendas"].include? table
      copy_deep_linking(objekt, new_objekt, child_event) 
    elsif ["feedback_forms", "awards", "invitee_structures", "panels"].include? table
      copy_association_having_association(objekt, new_objekt, child_event)
    end
  end

  #sponsors, agenda and speakers are assigned to polls, ekits, agenda. 
  #this method will assign the respective parent_id
  def self.copy_deep_linking(objekt, new_objekt, child_event)
    sponsor_id = child_event.sponsors.where("parent_id = ?", objekt.sponsor_id).last.id rescue nil
    if objekt.class == Poll
      agenda_ids = child_event.agendas.where("parent_id = ?", objekt.select_session).last.id rescue nil
      new_objekt.select_session = agenda_ids
    elsif objekt.class == EKit
      agenda_id = child_event.agendas.where("parent_id = ?", objekt.agenda_id).last.id rescue nil
      new_objekt.agenda_id = agenda_id
    elsif objekt.class == Agenda
      agenda_track_id = child_event.agenda_tracks.where("parent_id = ?", objekt.agenda_track_id).last.id rescue nil
      speaker_ids = child_event.speakers.where("parent_id IN (?)", objekt.speaker_ids.split(", ")).pluck(:id).join(", ") rescue nil
      new_objekt.agenda_track_id = agenda_track_id
      new_objekt.speaker_ids = speaker_ids
    end
    new_objekt.sponsor_id = sponsor_id
    new_objekt.save
  end

  def self.copy_association_having_association(objekt, new_parent_objekt, child_event)
    if objekt.class == FeedbackForm
      feedbacks = objekt.feedbacks
      if feedbacks.present?
        feedbacks.update_all(:feedback_form_id => new_parent_objekt.id)
      end 
    elsif objekt.class == Award
      winners = objekt.winners if objekt.winners.present?
      if winners.present?
        winners.each do |winner|
          new_objekt = winner.dup
          new_objekt.parent_id = winner.id
          new_objekt.award_id = new_parent_objekt.id
          new_objekt.save
        end
      end
    elsif objekt.class == Panel
      speaker_id = child_event.speakers.find_by_parent_id(new_parent_objekt.panel_id).id rescue nil
      new_parent_objekt.panel_id = speaker_id
      new_parent_objekt.save
    elsif objekt.class == InviteeStructure
      invitee_datum = objekt.invitee_datum if objekt.invitee_datum.present?
      if invitee_datum.present?
        invitee_datum.each do |invitee_data|
          new_objekt = invitee_data.dup
          new_objekt.parent_id = invitee_data.id
          new_objekt.invitee_structure_id = new_parent_objekt.id
          new_objekt.save
        end
      end 
    end
  end

  def self.remove_not_required_data(associations_to_clone, child_event)
    if associations_to_clone.exclude?("icon_library")
      child_event.default_feature_icon = "new_menu"
    end   
    if associations_to_clone.exclude?("abouts")
      child_event.about = nil
    end   
    if associations_to_clone.exclude?("activity_feeds")
      child_event.set_activity_feed_as_homepage = nil
      child_event.show_social_feeds = nil
      child_event.facebook_social_tags = nil
      child_event.twitter_social_tags = nil
      child_event.twitter_handle = nil
      child_event.instagram_client_id = nil
      child_event.instagram_secret_token = nil
      child_event.instagram_code = nil
    end   
    if associations_to_clone.present? and associations_to_clone.exclude?("event_highlights")
      child_event.description = nil
      child_event.countdown_ticker = nil
      child_event.rsvp = nil
      child_event.rsvp_message = nil
      child_event.highlight_saved = nil
    end  
    associations_to_clone = associations_to_clone - ['abouts','activity_feeds','event_highlights','icon_library']
    associations_to_clone
  end

  def self.get_association_name(feature_name)
    feature_hash ={}
    feature_hash["galleries"] = ["folders","images"]
    feature_hash["event_highlights"] = ["highlight_images", "event_highlights"]
    feature_hash["venue"] = ["emergency_exit"]
    feature_hash["my_profile"] = ["my_profiles"]
    feature_hash["content"] = nil
    feature_hash["engagement"] = nil
    feature_hash["activity_feeds"] = ["activity_feeds"]
    feature_hash["database"] = ["invitee_structures", "groupings"]
    feature_hash["registration"] = ["registration_settings", "registrations", "registration_edms", "registration_look_and_feels"]
    feature_hash["feedbacks"] = ["feedback_forms","feedbacks"]
    feature_hash["telecaller"] = ["telecaller_user"]
    feature_hash["communication"] = ["communication_campaigns"]
    feature_hash["maps"] = ["map"]
    feature_hash["qnas"] = ["panels", "qna_settings"]
    feature_hash["agendas"] = ["agenda_tracks", "agendas"]
    feature_hash["#{feature_name}"]
  end
end
