class EventFeatureSerializer < ActiveModel::Serializer

  def attributes
	  data = super
    data[:id] = object.id
    data[:name] = object.name
    data[:event_id] = object.event_id
    data[:page_title] = object.page_title
    data[:sequence] = object.sequence
    data[:status] = object.status
    data[:description] = object.description
    data[:menu_visibilty] = object.menu_visibilty
    data[:menu_icon_visibility] = object.menu_icon_visibility
    data[:session_to_agenda] = object.session_to_agenda
    data[:main_icon_updated_at] = object.main_icon_updated_at
    data[:menu_icon_updated_at] = object.menu_icon_updated_at
    data[:show_event_feature] = object.show_event_feature
    data[:main_icon_url] = object.main_icon_url
    data[:menu_icon_url] = object.menu_icon_url
    data[:image_setting] = object.image_setting
    Hash[*data.map{|k, v| v.nil? ? [k, v || ""] : [k, v]}.flatten]
	end
end
