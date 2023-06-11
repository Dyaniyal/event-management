class ThemeSerializer < ActiveModel::Serializer
  def attributes 
  	data = super
  	data[:id] = object.id
  	data[:name] = object.name
  	data[:skin_image] = object.skin_image
  	data[:content_font_color] = object.content_font_color
  	data[:button_color] = object.button_color
  	data[:button_content_color] = object.button_content_color
  	data[:drawer_menu_back_color] = object.drawer_menu_back_color
  	data[:drawer_menu_font_color] = object.drawer_menu_font_color
  	data[:created_at] = object.created_at
  	data[:updated_at] = object.updated_at
  	data[:bar_color] = object.bar_color
  	data[:event_background_image_url] = object.event_background_image_url
	  data[:header_color] = object.header_color
	  data[:footer_color] = object.footer_color
	  data[:background_color] = object.background_color
	  Hash[*data.map{|k, v| v.nil? ? [k, v || ""] : [k, v]}.flatten]
  end
 end
