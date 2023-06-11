class UserPollSerializer < ActiveModel::Serializer

	def attributes 
		data = super
		data[:id] = object.id
		data[:user_id] = object.user_id
		data[:poll_id] = object.poll_id
		data[:answer] = object.answer
		data[:created_at] = object.created_at
		data[:updated_at] = object.updated_at
		
		Hash[*data.map{|k, v| v.nil? ? [k, v || ""] : [k, v]}.flatten]
	end
end
