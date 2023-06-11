require 'rubygems'

module ReviewStatus

  def self.review(objekt, features_arr, extra_count=0, total_count=nil)
    #features_arr = {'name' => '', 'application_type@@multi event' => ['listing_screen_background'], 'template_id' => '', 'app_icon' => '', 'login_at@@yes' => ['login_background']}
    count = 0
    total = total_count || features_arr.length
    missing_arr = []
    features_arr.each do |feature|
      if objekt.attribute_present? (feature)
        count += 1
      else
        missing_arr << feature
      end
    end
    count += extra_count
    [(((((count/total.to_f) * 100).to_i) / 10) * 10), missing_arr]
  end


  # def self.review(objekt, features_arr)
  #   #features_arr = {'name' => '', 'application_type@@multi event' => ['listing_screen_background'], 'template_id' => '', 'app_icon' => '', 'login_at@@yes' => ['login_background']}
  #   count, total = 0, features_arr.length
  #   missing_arr = []
  #   features_arr.keys.each do |feature|
  #     field_name, value = feature.split('@@')
  #     condn = (objekt.attribute_present? (field_name) and (value.blank? or (value.present? and objekt.attributes[field_name] == value)))
  #     if condn
  #       count, total = count+1, (total+features_arr[feature].length)
  #       if features_arr[feature].present?
  #         features_arr[feature].each do |sub_feature|
  #           sub_field_name, sub_value = sub_feature.split('@@')  
  #           count += 1 if objekt.attribute_present? (sub_field_name) and (sub_value.blank? or (sub_value.present? and objekt.attributes[sub_field_name] == sub_value))
  #         end
  #       end
  #     end
  #     missing_arr << field_name if condn == false
  #   end
  #   [(((((count/total.to_f) * 100).to_i) / 10) * 10), missing_arr]
  # end

  # def self.event_content_status(objekt, )
  #   features = objekt.event_features.pluck(:name)
  #   not_enabled_feature = Event::EVENT_FEATURE_ARR - features
  #   #features += ['contacts', 'emergency_exit', 'event_highlights', 'highlight_images']
  #   count = 0
  #   total_content_count = features.count
  #   content_missing_arr = []
  #   features.each do |feature|
  #     feature = 'images' if feature == 'galleries'
  #     condition = self.association(feature).count <= 0 if !(feature == 'abouts' or feature == 'notes' or feature == 'event_highlights') and (feature != 'emergency_exits' and feature != 'emergency_exit')
  #     condition, feature = EmergencyExit.where(:event_id => self.id).blank?, 'emergency_exits' if feature == 'emergency_exits' or feature == 'emergency_exit'
  #     if (condition or (feature == 'abouts' and self.about.blank? or ((feature == 'event_highlights' and self.description.blank?) or (feature == 'event_highlights' and self.summary.blank?) ))) and ['qnas', 'conversations'].exclude? feature
  #       count += 1
  #       content_missing_arr << feature
  #     end
  #   end
  #   percent = (((count/total_content_count.to_f) * 100) == 0.0)? 100 : (100 - ((count/total_content_count.to_f) * 100)) if total_content_count != 0
  #   [content_missing_arr, not_enabled_feature, percent.to_i]
  # end

end
