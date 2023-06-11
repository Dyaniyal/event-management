class QuizSerializer < ActiveModel::Serializer
  # attributes :id, :question, :option1, :option2, :option3, :option4, :option5, :option6, :status, :sequence, :event_id, :correct_answer, :get_correct_answer_percentage, :get_total_answer, :get_correct_answer_count

  def attributes
  	data = super
  	data[:id] = object.id
  	data[:question] = object.question
  	data[:option1] = object.option1
  	data[:option2] = object.option2
  	data[:option3] = object.option3
  	data[:option4] = object.option4
  	data[:option5] = object.option5
  	data[:option6] = object.option6
  	data[:status] = object.status
  	data[:sequence] = object.sequence
  	data[:event_id] = object.event_id
  	data[:correct_answer] = object.correct_answer[0] rescue ''
  	data[:get_correct_answer_percentage] = object.get_correct_answer_percentage
  	data[:get_total_answer] = object.get_total_answer
  	data[:get_correct_answer_count] = object.get_correct_answer_count
  	Hash[*data.map{|k, v| v.nil? ? [k, v || ""] : [k, v]}.flatten]
  end
end
