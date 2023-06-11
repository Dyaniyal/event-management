class PanelSerializer < ActiveModel::Serializer
  attributes :id, :name, :event_id, :panel_type, :sequence, :hide_panel
end
