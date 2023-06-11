class FeedbackFormSerializer < ActiveModel::Serializer
  
  def attributes 
    data = super
    data[:id] = object.id
    data[:sequence] = object.sequence
    data[:title] = object.title
    data[:event_id] = object.event_id
    data[:created_at] = object.created_at
    data[:updated_at] = object.updated_at
    data[:status] = object.status
    data[:submission_msg] = object.submission_msg
    Hash[*data.map{|k, v| v.nil? ? [k, v || ""] : [k, v]}.flatten]
  end
end
