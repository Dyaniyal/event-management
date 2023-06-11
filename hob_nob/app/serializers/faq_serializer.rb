class FaqSerializer < ActiveModel::Serializer

 def attributes 
    data = super
    data[:id] = object.id
    data[:question] = object.question
    data[:answer] = object.answer
    data[:event_id] = object.event_id
    data[:user_id] = object.user_id
    data[:created_at] = object.created_at
    data[:updated_at] = object.updated_at
    data[:sequence] = object.sequence
    data[:event_timezone] = object.event_timezone
    data[:event_timezone_offset] = object.event_timezone_offset
    data[:event_display_time_zone] = object.event_display_time_zone
    data[:last_force_destroyed] = object.last_force_destroyed
    data[:parent_id] = object.parent_id
    Hash[*data.map{|k, v| v.nil? ? [k, v || ""] : [k, v]}.flatten]
  end
end
