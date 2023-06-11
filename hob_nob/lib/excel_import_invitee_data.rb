require 'rubygems'
require 'roo'
# require 'zip/zipfilesystem'
#include ActiveSupport::Inflector

module ExcelImportInviteeData

  def self.process_import_invitee_data
    in_progess_imports_count = Import.where(status: 'In Progress', importable_type: 'invitee_data').count
    if in_progess_imports_count < 2
      import = Import.unscoped.where(status: 'Pending', importable_type: 'invitee_data').order(:row_count).first
      if import.present?
        import.update_attribute(:status, 'In Progress')
        begin
          save(
            import.import_file.url.split("?").first,
            import.importable_type,
            import.importable_id,
            import.importable_type.classify.constantize.column_names,
            nil,
            { start_row: 2, import: import.id }
          )
        rescue => e
          imp_attr = { log_file: [['Line No.', 'Row Data' , 'Status', 'Description'], ['1', 'row', 'error', e]], status: 'Failed' }
          import.update_import(imp_attr)
        end
      end
    end
  end
#options => {:start_row => 'start_row_number'}
  def self.save(file_path, klass_name, event_id,attributes=[], operation='add', options={})
    event = Event.find(event_id)
    event_structure = event.invitee_structures.first
    attributes = event_structure.attributes.except('id', 'created_at', 'updated_at', 'event_id', 'uniq_identifier','email_field','mandate_attr2','mandate_attr3','mandate_attr4','mandate_attr5','mandate_attr6','mandate_attr7','mandate_attr8','mandate_attr9','mandate_attr10','mandate_attr11','mandate_attr12','mandate_attr13','mandate_attr14','mandate_attr15','mandate_attr16','mandate_attr17','mandate_attr18','mandate_attr19','mandate_attr20','mandate_attr21','mandate_attr22','mandate_attr23','mandate_attr24','mandate_attr25','mandate_attr26','mandate_attr27','mandate_attr28','mandate_attr29','mandate_attr30','parent_id','multi_lng_parent_id','language_updated','expiry_date').map{|k, v| v.to_s.length > 0 ? v : nil}.compact
    self.prepare_objekts(file_path, klass_name, event_id, attributes, operation, options)
  end

  def self.update(file_path, klass_name, attributes=[], operation='add', options={})
    objekts = self.prepare_objekts(file_path, klass_name, attributes, operation, options)
    return {:is_saved => true}
  end

  def self.prepare_objekts(file_path, klass_name, event_id, attributes, operation, options)
    ext = File.extname(file_path)
    workbook = nil
    if File.extname(file_path) == ".xlsx"
      workbook = Roo::Excelx.new(file_path)
    elsif File.extname(file_path) == ".xls"
      workbook = Roo::Excel.new(file_path)
    end
    start_row = options[:start_row] || 1
    columns_in_worksheet = []
    column_match_errors = nil
    workbook.default_sheet = workbook.sheets.first
    0.upto(workbook.last_column) do |col|
      columns_in_worksheet << workbook.cell(workbook.first_row, col)
    end
    columns_in_worksheet = columns_in_worksheet.compact
    letters_array = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z","AA", "AB", "AC", "AD", "AE", "AF", "AG", "AH", "AI", "AJ", "AK", "AL", "AM", "AN", "AO", "AP", "AQ", "AR", "AS", "AT", "AU", "AV", "AW", "AX", "AY", "AZ"]
    
    event = Event.find(event_id)
    invitee_structure = event.invitee_structures.first
    identifier_key = invitee_structure.attributes[invitee_structure.uniq_identifier].downcase
    object_attributes = invitee_structure.attributes.except('id', 'created_at', 'updated_at', 'event_id', 'uniq_identifier','email_field','mandate_attr2','mandate_attr3','mandate_attr4','mandate_attr5','mandate_attr6','mandate_attr7','mandate_attr8','mandate_attr9','mandate_attr10','mandate_attr11','mandate_attr12','mandate_attr13','mandate_attr14','mandate_attr15','mandate_attr16','mandate_attr17','mandate_attr18','mandate_attr19','mandate_attr20','mandate_attr21','mandate_attr22','mandate_attr23','mandate_attr24','mandate_attr25','mandate_attr26','mandate_attr27','mandate_attr28','mandate_attr29','mandate_attr30','parent_id','multi_lng_parent_id','language_updated','expiry_date').map{|k, v| v.to_s.length > 0 ? [k, v.parameterize('_').strip.downcase] : nil}.compact
    import = Import.find(options[:import])
    import_attr = { log_file: [['Line No.', 'Row Data' , 'Status', 'Description']] }

    arr = attributes.zip(columns_in_worksheet).map{ |x, y| (x.to_s.strip.downcase == y.to_s.strip.downcase) or (x.to_s.strip.downcase.gsub("_"," ").gsub("-"," ") == y.to_s.strip.downcase)}
    column_match_errors = arr.include? false        

    if column_match_errors
      update_import_hash(import_attr, [1, 'row1'], 'error', 'Columns Does not match')
      import.update_import(import_attr.merge(status: 'Failed'))
      import.update_attribute(:error_count, import.error_count + 1)
      { is_saved: false, excel_errors: 'row1 :  Columns Does not match' }
    elsif workbook.last_row > 15001
      update_import_hash(import_attr, [1, 'rows'], 'error', 'Records out of limit (must be < 15000)')
      import.update_import(import_attr.merge(status: 'Failed'))
      import.update_attribute(:error_count, import.error_count + 1)
      { is_saved: false, excel_errors: 'Records out of limit (must be < 15000)' }
    else
      start_row.upto(workbook.last_row) do |line|
        objekt = nil
        objekt = {}
        columns_in_worksheet.each_with_index do |attrib, index|
          if workbook.cell(line, letters_array[index]).present?
            set_value = workbook.cell(line, letters_array[index]).is_a?(Numeric) ? workbook.cell(line, letters_array[index]).ceil.to_s : workbook.cell(line, letters_array[index]).to_s.strip
            objekt[attrib.to_s.parameterize('_').strip.downcase] = set_value rescue ''
          end
        end
        begin
          saving_invitee_data(object_attributes, import_attr, invitee_structure, identifier_key, objekt, line, import)
        rescue ActiveRecord::RecordNotUnique
          saving_invitee_data(object_attributes, import_attr, invitee_structure, identifier_key, objekt, line, import)
        end
      end
      import.update_import(import_attr.merge(status: 'Completed'))
      { is_saved: true }
    end
  end

  def self.saving_invitee_data(object_attributes, import_attr, invitee_structure, identifier_key, objekt, line, import)
    invitee_data = InviteeDatum.find_or_initialize_by(
      invitee_structure_id: invitee_structure.id,
      invitee_structure.uniq_identifier => objekt[identifier_key.gsub(' ', '_')]
    )
    is_new_entry = invitee_data.new_record?
    invitee_data.skip_status_update = "true"
    invitee_hsh = {}
    object_attributes.each do |object_attribute|
      invitee_hsh[object_attribute[0]] = objekt[object_attribute[1].downcase].to_s rescue ""
    end
    invitee_data.assign_attributes(invitee_hsh)
    row_data = "'#{invitee_data.attr1.present? ? invitee_data.attr1 : "row#{line}"}'"
    if invitee_data.save
      if is_new_entry
        import.update_attribute(:created_count, import.created_count + 1)
      else
        import.update_attribute(:updated_count, import.updated_count + 1)
      end
      update_import_hash(import_attr, [line, row_data], is_new_entry ? 'created' : 'updated')
    else
      import.update_attribute(:error_count, import.error_count + 1)
      error_log = "#{invitee_data.errors.full_messages.map{|a| a.gsub("Attr","Column")}.join(", ")}"
      update_import_hash(import_attr, [line, row_data], 'error', error_log)
    end
  end

  def self.update_import_hash(import_attr, row_data, type, log=nil)
    import_attr[:log_file] << [row_data[0], row_data[1], type, log]
  end

end
