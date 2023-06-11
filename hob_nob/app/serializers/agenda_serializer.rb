class AgendaSerializer < ActiveModel::Serializer
  
  def attributes
  	data = super
    data["id"] = object.id
    data["event_name"] = object.event_name
    data["event_time"] = object.event_time
    data["speaker_name"] = object.speaker_name
    data["options"] = object.options
    data["event_id"] = object.event_id
    data["created_at"] = object.created_at
    data["updated_at"] = object.updated_at
    data["discription"] = object.discription
    data["agenda_date"] = object.agenda_date
    data["start_agenda_time"] = object.start_agenda_time
    data["end_agenda_time"] = object.end_agenda_time
    data["title"] = object.title
    data["speaker_id"] = object.speaker_id
    data["start_agenda_date"] = object.start_agenda_date
    data["end_agenda_date"] = object.end_agenda_date
    data["rating_status"] = object.rating_status
    data["agenda_type"] = object.agenda_type
    data["sequence"] = object.sequence
    data["event_timezone"] = object.event_timezone
    data["agenda_track_id"] = object.agenda_track_id
    data["old_start_agenda_time"] = object.old_start_agenda_time
    data["old_start_agenda_date"] = object.old_start_agenda_date
    data["old_end_agenda_date"] = object.old_end_agenda_date
    data["old_end_agenda_time"] = object.old_end_agenda_time
    data["parent_id"] = object.parent_id
    data["event_timezone_offset"] = object.event_timezone_offset
    data["event_display_time_zone"] = object.event_display_time_zone
    data["speaker_ids"] = object.speaker_ids
    data["speaker_names"] = object.speaker_names
    data["all_speaker_names"] = object.all_speaker_names
    data["ratings_count_cache"] = object.ratings_count_cache
    data["last_force_destroyed"] = object.last_force_destroyed
    data["multi_lng_parent_id"] = object.multi_lng_parent_id
    data["language_updated"] = object.language_updated
    data["show_agenda_feature"] = object.show_agenda_feature
    data["sponsor_id"] = object.sponsor_id
    data["ask_an_question"] = object.ask_an_question
    data["location"] = object.location
    data["way_finder"] = object.way_finder
    data["way_location"] = object.way_location
    data["agenda_track_name"] = object.agenda_track_name
    data["track_sequence"] = object.track_sequence
    data["formatted_start_date_detail"] = object.formatted_start_date_detail
    data["formatted_time"] = object.formatted_time
    data["formatted_start_date_listing"] = object.formatted_start_date_listing
    data["formatted_time_without_timezone"] = object.formatted_time_without_timezone
    Hash[*data.map{|k, v| v.nil? ? [k, v || ""] : [k, v]}.flatten]
  end
end


