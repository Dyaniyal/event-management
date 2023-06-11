class EmergencyExitSerializer < ActiveModel::Serializer

  def attributes
	  data = super
    data[:id] = object.id
	  data[:event_name] = object.event_name
	  data[:event_id] = object.event_id
	  data[:title] = object.title
	  data[:emergency_exit_url] = object.emergency_exit_url
	  data[:icon_url] = object.icon_url
    Hash[*data.map{|k, v| v.nil? ? [k, v || ""] : [k, v]}.flatten]
	end
end
