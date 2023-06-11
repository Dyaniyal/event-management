class QnaSerializer < ActiveModel::Serializer

  def attributes 
    data = super
  	data[:id] = object.id
    data[:question] = object.question
    data[:answer] = object.answer
    data[:sender_id] = object.sender_id
    data[:receiver_id] = object.receiver_id
    data[:event_id] = object.event_id
    data[:status] = object.status
    data[:created_at] = object.created_at
    data[:updated_at] = object.updated_at
    data[:on_wall] = object.on_wall
    data[:wall_answer] = object.wall_answer
    data[:anonymous_on_wall] = object.anonymous_on_wall
    data[:last_force_destroyed] = object.last_force_destroyed
    data[:user_answered] = object.user_answered
    data[:get_speaker_name] = object.get_speaker_name
    data[:get_user_name] = object.get_user_name
    data[:get_company_name] = object.get_company_name
    data[:formatted_created_at_for_qna] = object.formatted_created_at_for_qna
    data[:formatted_updated_at_for_qna] = object.formatted_updated_at_for_qna
    data[:invitee_profile_pic] = object.invitee_profile_pic
    data[:formatted_created_date_for_display] = object.formatted_created_date_for_display
    data[:formatted_updated_date_for_display] = object.formatted_updated_date_for_display
    data[:get_panel_name] = object.get_panel_name
    Hash[*data.map{|k, v| v.nil? ? [k, v || ""] : [k, v]}.flatten]
  end
end
