class AwardSerializer < ActiveModel::Serializer

  def attributes
  	data = super
    data["id"] = object.id
    data["event_id"] = object.event_id
    data["title"] = object.title
    data["description"] = object.description
    data["sequence"] = object.sequence
    Hash[*data.map{|k, v| v.nil? ? [k, v || ""] : [k, v]}.flatten]
  end
end
