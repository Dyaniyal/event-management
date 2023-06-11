require 'rubygems'
require 'roo'
# require 'zip/zipfilesystem'
#include ActiveSupport::Inflector

module ExcelImportUserRegistration          
#options => {:start_row => 'start_row_number'}
  def self.save(file_path, klass_name, event_id,attributes=[], operation='add', options={})
    event = Event.find(event_id)    
    registration_form = event.registrations.first
    attributes = registration_form.selected_columns
    objekts = self.prepare_objekts(file_path, klass_name, event_id, attributes, operation, options)
    errors = ExcelImportUserRegistration.validate_objekts(objekts)
    if errors.blank?
      ExcelImportUserRegistration.save_objekts(objekts[0])
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

  def self.prepare_objekts(file_path, klass_name, event_id, attributes, operation, options)
    # ENV['ROO_TMP'] = "#{Rails.root}/tmp"
    ext = File.extname(file_path)
    puts ext
    workbook = nil
    if File.extname(file_path) == ".xlsx"
      workbook = Roo::Excelx.new(file_path)
    elsif File.extname(file_path) == ".xls"
      workbook = Roo::Excel.new(file_path)
    end
   start_row = options[:start_row] || 1
   objekts = []
   columns_in_worksheet = []
   column_match_errors = nil
   workbook.default_sheet = workbook.sheets.first
   0.upto(workbook.last_column) do |col|
     columns_in_worksheet << workbook.cell(workbook.first_row, col)
   end
   columns_in_worksheet = columns_in_worksheet.compact
   letters_array = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z","AA", "AB", "AC", "AD", "AE", "AF", "AG", "AH", "AI", "AJ", "AK", "AL", "AM", "AN", "AO", "AP", "AQ", "AR", "AS", "AT", "AU", "AV", "AW", "AX", "AY", "AZ"]
    start_row.upto(workbook.last_row) do |line|
      objekt = nil
      objekt = {} #klass_name.classify.constantize.new()
      columns_in_worksheet.each_with_index do |attrib, index|
        if workbook.cell(line, letters_array[index]).present?
          set_value = workbook.cell(line, letters_array[index]).is_a?(Numeric) ? workbook.cell(line, letters_array[index]).ceil.to_s : workbook.cell(line, letters_array[index]).strip
          #objekt[attrib.parameterize('_').strip.downcase] = set_value rescue ''
          objekt[attrib.downcase] = set_value rescue ''
        end
      end
      arr = attributes.zip(columns_in_worksheet).map{ |x, y| x.to_s.strip.downcase == y.to_s.strip.downcase }
      column_match_errors = arr.include? false
      event = Event.find(event_id)
      registration_form = event.registrations.first
      identifier_key = registration_form.attributes["email_field"].downcase
      identifier_value = registration_form[registration_form.attributes["email_field"].downcase]["label"] #objekt[identifier_key]
      
      user_data = UserRegistration.new()
      # user_data = UserRegistration.find_or_initialize_by(registration_form.attributes["email_field"].downcase => objekt[registration_form[registration_form.attributes["email_field"].downcase]["label"]], :registration_id => registration_form.id)

      # invitee_data = UserRegistration.find_or_initialize_by(registration_form.attributes["email_field"].downcase => objekt[identifier_key.gsub(' ', '_')], :registration_id => registration_form.id)
      #invitee_data.skip_status_update = "true"
      user_hsh = {}
      object_attributes = registration_form.selected_columns
      object_attributes << "event_id"
      object_attributes << "import_user_registration"
      object_attributes.each do |object_attribute|
        if object_attribute == "event_id"
          user_hsh[object_attribute] = event.id rescue ""
        elsif object_attribute == "import_user_registration"
          user_data.import_user_registration = "true"
        else
          user_hsh[object_attribute] = objekt[registration_form.attributes[object_attribute]["label"].downcase] rescue ""
        end
      end
      user_data.assign_attributes(user_hsh)
      objekts << user_data
    end
    [objekts.compact, column_match_errors]
  end

  def self.validate_objekts(objekts)
    error_rows = []
    objekts[0].each_with_index do |objekt, index|
      error_rows << "row#{index + 2} :   #{objekt.errors.full_messages.join(", ")}\n" if objekt.invalid?
      Rails.logger.info objekt.errors.inspect
    end
    error_rows
  end

  def self.save_objekts(objekts)
    objekts.each do |objekt|
      objekt.save(:validate=>false)
      edm = Campaign.find_by_id(0).edms.where(mail_to: objekt.status, event_id: objekt.event_id).first
      edm.send_mail_to_register_user(objekt) if edm.present?
    end
  end

end