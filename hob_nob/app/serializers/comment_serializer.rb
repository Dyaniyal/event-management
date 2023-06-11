class CommentSerializer < ActiveModel::Serializer

  def attributes
  	data = super
    data["id"] = object.id
    data["commentable_id"] = object.commentable_id
    data["commentable_type"] = object.commentable_type
    data["user_id"] = object.user_id
    data["description"] = object.description
    data["analytic_id"] = object.analytic_id
		data["user_name"] = object.user_name
		data["formatted_created_at_with_event_timezone"] = object.formatted_created_at_with_event_timezone
		data["formatted_updated_at_with_event_timezone"] = object.formatted_updated_at_with_event_timezone
		data["first_name"] = object.first_name
		data["last_name"] = object.last_name
    Hash[*data.map{|k, v| v.nil? ? [k, v || ""] : [k, v]}.flatten]
  end
end
