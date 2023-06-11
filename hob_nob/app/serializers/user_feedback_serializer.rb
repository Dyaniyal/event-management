class UserFeedbackSerializer < ActiveModel::Serializer

  def attributes 
  	data = super
  	data[:id] = object.id
    data[:feedback_id] =  object.feedback_id
    data[:user_id] =  object.user_id
    data[:answer] = object.answer
    data[:description] =  object.description
    data[:event_id] = object.event_id
    data[:feedback_form_id] = object.feedback_form_id
	  Hash[*data.map{|k, v| v.nil? ? [k, v || ""] : [k, v]}.flatten]
  end
end
