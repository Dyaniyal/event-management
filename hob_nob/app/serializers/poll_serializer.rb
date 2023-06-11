class PollSerializer < ActiveModel::Serializer

  def attributes 
  	data = super
  	data[:id] = object.id
  	data[:option1] = object.option1
  	data[:option2] = object.option2
  	data[:option3] = object.option3
  	data[:option4] = object.option4
  	data[:option5] = object.option5
  	data[:option6] = object.option6
  	data[:event_id] = object.event_id
  	data[:created_at] = object.created_at
  	data[:updated_at] = object.updated_at
  	data[:poll_start_date_time] = object.poll_start_date_time
  	data[:poll_end_date_time] = object.poll_end_date_time
	data[:status] = object.status
	data[:sequence] = object.sequence
	data[:question] = object.question
	data[:option_visible] = object.option_visible
	data[:event_timezone] = object.event_timezone
	data[:option_type] = object.option_type
	data[:description] = object.description
	data[:option7] = object.option7
	data[:option8] = object.option8
	data[:option9] = object.option9
	data[:option10] = object.option10
	data[:rating_first_text] = object.rating_first_text
	data[:rating_second_text] = object.rating_second_text
	data[:select_session] = object.select_session
	data[:show_poll_at] = object.show_poll_at
	data[:sponsor_id] = object.sponsor_id
	data[:option_percentage] = object.option_percentage
	Hash[*data.map{|k, v| v.nil? ? [k, v || ""] : [k, v]}.flatten]
  end
end
