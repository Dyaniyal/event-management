class EKitSerializer < ActiveModel::Serializer

  def attributes
  	data = super
    data["id"] = object.id
    data["event_id"] = object.event_id
    data["name"] = object.name
    data["agenda_id"] = object.agenda_id
    data["sponsor_id"] = object.sponsor_id
    data["show_e_kit_feature"] = object.show_e_kit_feature
    data["sub_folder"] = object.sub_folder

    data["folder_name"] = object.folder_name
    data["attachment_url"] = object.attachment_url
    data["attachment_type"] = object.attachment_type
    Hash[*data.map{|k, v| v.nil? ? [k, v || ""] : [k, v]}.flatten]
  end
end
