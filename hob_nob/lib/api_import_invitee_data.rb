require 'rubygems'
require 'roo'
# require 'zip/zipfilesystem'
#include ActiveSupport::Inflector

module ApiImportInviteeData
#options => {:start_row => 'start_row_number'}
  def self.save(response, klass_name, event_id,attributes=[], operation='add', options={})
    event = Event.find(event_id)
    event_structure = event.invitee_structures.first
    attributes = event_structure.attributes.except('id', 'created_at', 'updated_at', 'event_id', 'uniq_identifier','email_field','mandate_attr2','mandate_attr3','mandate_attr4','mandate_attr5','mandate_attr6','mandate_attr7','mandate_attr8','mandate_attr9','mandate_attr10','mandate_attr11','mandate_attr12','mandate_attr13','mandate_attr14','mandate_attr15','mandate_attr16','mandate_attr17','mandate_attr18','mandate_attr19','mandate_attr20','parent_id','language_updated','multi_lng_parent_id','expiry_date').map{|k, v| v.to_s.length > 0 ? v : nil}.compact
    objekts = ApiImportInviteeData.prepare_objekts(response, 'klass_name', event.id, attributes, 'add', options)
    errors = ApiImportInviteeData.validate_objekts(objekts)
    if errors.blank?
      ApiImportInviteeData.save_objekts(objekts[0])
      return {:is_saved => true}
    else
      excel_errors = "Errors found at rows: #{errors.to_sentence}"
      return {:is_saved => false, :excel_errors => excel_errors}
    end
  end

  def self.update(file_path, klass_name, attributes=[], operation='add', options={})
    objekts = self.prepare_objekts(file_path, klass_name, attributes, operation, options)
    return {:is_saved => true}
  end

  def self.prepare_objekts(response, klass_name, event_id, attributes, operation, options)
    # ENV['ROO_TMP'] = "#{Rails.root}/tmp"
   start_row = options[:start_row] || 1
   objekts = []
   columns_in_worksheet = []
   column_match_errors = nil
   columns_in_worksheet = columns_in_worksheet.compact
    # start_row.upto(workbook.last_row) do |line|
    response["ResponseData"].each do |line|
      objekt = nil
      objekt = {} #klass_name.classify.constantize.new()
      columns_in_worksheet = line.keys.drop(2)
      # columns_in_worksheet = line.keys
      line.each do |key, value|
        objekt[key.parameterize('_').strip.downcase] = value rescue ''
      end
      arr = attributes.zip(columns_in_worksheet).map{ |x, y| x.to_s.strip.downcase == y.to_s.strip.downcase }
      column_match_errors = arr.include? false
      event = Event.find(event_id)
      unless column_match_errors
        invitee_structure = event.invitee_structures.first
        identifier_key = invitee_structure.attributes[invitee_structure.uniq_identifier].downcase
        identifier_value = objekt[identifier_key]
        invitee_data = InviteeDatum.find_or_initialize_by(:invitee_structure_id => invitee_structure.id, invitee_structure.uniq_identifier => objekt[identifier_key.gsub(' ', '_')])
        invitee_data.skip_status_update = "true"
        invitee_hsh = {}
        object_attributes = invitee_structure.attributes.except('id', 'created_at', 'updated_at', 'event_id', 'uniq_identifier','email_field','mandate_attr2','mandate_attr3','mandate_attr4','mandate_attr5','mandate_attr6','mandate_attr7','mandate_attr8','mandate_attr9','mandate_attr10','mandate_attr11','mandate_attr12','mandate_attr13','mandate_attr14','mandate_attr15','mandate_attr16','mandate_attr17','mandate_attr18','mandate_attr19','mandate_attr20','language_updated','multi_lng_parent_id','expiry_date').map{|k, v| v.to_s.length > 0 ? [k, v.parameterize('_').strip.downcase] : nil}.compact
        object_attributes.each do |object_attribute|
          invitee_hsh[object_attribute[0]] = objekt[object_attribute[1].downcase].to_s rescue ""
        end
        #check_email = objekts.map{|o| o.send(invitee_structure.uniq_identifier).include?(invitee_hsh[invitee_structure.uniq_identifier]) ? invitee_hsh[invitee_structure.uniq_identifier] : nil}.compact
        check_email = objekts.map{|o| o.send(invitee_structure.uniq_identifier) == invitee_hsh[invitee_structure.uniq_identifier] ? invitee_hsh[invitee_structure.uniq_identifier] : nil}.compact
        if check_email.empty? #or check_email == true
          invitee_data.assign_attributes(invitee_hsh)
          objekts << invitee_data
        elsif check_email.present? #check_email == false
          invitee_data = objekts.map{|o| o.send(invitee_structure.uniq_identifier) == invitee_hsh[invitee_structure.uniq_identifier] ? o : nil}.compact.first
          invitee_data.assign_attributes(invitee_hsh) rescue nil
        end
      end
    end
    [objekts.compact, column_match_errors]
  end
  
  def self.validate_objekts(objekts)
    error_rows = []
    if objekts[1] == false
      objekts[0].each_with_index do |objekt, index|
        #error_rows << "row#{index + 2} :   #{objekt.errors.full_messages.join(", ")}\n" if objekt.invalid?
        # for email fields
        # error_rows << "row#{index + 2} :   #{objekt.errors.full_messages.map{|a| a.gsub("Attr","Column")}.join(", ")}\n" if objekt.invalid?
        error_rows << "'#{objekt.attr1.present? ? objekt.attr1 : "row#{index + 2}"}' :   #{objekt.errors.full_messages.map{|a| a.gsub("Attr","Column")}.join(", ")}\n" if objekt.invalid?
        Rails.logger.info objekt.errors.inspect
      end
    else
      error_rows << "row#{1} :  Columns Does not match"
    end
    error_rows
  end

  def self.save_objekts(objekts)
    objekts.each do |objekt|
      objekt.save
    end
  end

end