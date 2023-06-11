class QnaSettingSerializer < ActiveModel::Serializer
  
  def attributes 
	  data = super
    data[:id] = object.id
	  data[:event_id] = object.event_id
	  data[:display_qna_on_app] = object.display_qna_on_app
	  data[:created_at] = object.created_at
	  data[:updated_at] = object.updated_at
	  data[:multi_lng_parent_id] = object.multi_lng_parent_id
	  data[:language_updated] = object.language_updated
	  data[:description] = object.description
	  data[:ask_a_question_to] = object.ask_a_question_to
	  data[:parent_id] = object.parent_id
    Hash[*data.map{|k, v| v.nil? ? [k, v || ""] : [k, v]}.flatten]
	end
end


