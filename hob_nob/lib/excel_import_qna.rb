require 'rubygems'
require 'roo'
# require 'zip/zipfilesystem'
#include ActiveSupport::Inflector

module ExcelImportQna
#options => {:start_row => 'start_row_number'}
  def self.save(file_path, klass_name, event_id,attributes=[], operation='add', options={})
    attributes = Qna.column_names
    attributes -= ["id","created_at", "updated_at","sender_id","receiver_id"]
    objekts = self.prepare_objekts(file_path, klass_name, event_id, attributes, operation, options)
    errors = ExcelImportQna.validate_objekts(objekts)
    if errors.blank?
      ExcelImportQna.save_objekts(objekts)
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
   workbook.default_sheet = workbook.sheets.first
   0.upto(workbook.last_column) do |col|
     columns_in_worksheet << workbook.cell(workbook.first_row, col)
   end
   columns_in_worksheet.compact!
   letters_array = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z","AA", "AB", "AC", "AD", "AE", "AF", "AG", "AH", "AI", "AJ", "AK", "AL", "AM", "AN", "AO", "AP", "AQ", "AR", "AS", "AT", "AU", "AV", "AW", "AX", "AY", "AZ"]
    start_row.upto(workbook.last_row) do |line|
      objekt = nil
      objekt = {} #klass_name.classify.constantize.new()
      columns_in_worksheet.each_with_index do |attrib, index|
        objekt[attrib.parameterize('_').strip] = workbook.cell(line, letters_array[index]).strip rescue ''
      end
      event = Event.find_by_id(event_id)
      sender_id = event.invitees.find_by_email(objekt["invitee_email"]).id rescue nil
      # if objekt["receiver_type"] == "speaker"
      #   panel_id = Speaker.find_by_speaker_name(objekt["receiver_name"].strip).id rescue nil
      # elsif objekt["receiver_type"] == "invitee"
      #   panel_id = Invitee.find_name_of_the_invitee(objekt["receiver_name"].strip).id rescue nil
      # end
      receiver_id = event.speakers.find_by_speaker_name(objekt["speaker_name"].strip).id rescue nil
      # receiver_id = Panel.find_by_panel_id(panel_id).id rescue nil
      receiver_id = Panel.find_by_name(objekt["speaker_name"].strip).id if receiver_id.nil?  rescue nil
      qna = Qna.find_or_initialize_by(:event_id => event_id,:question => objekt["question"], :sender_id => sender_id, :receiver_id => receiver_id)
      qna.assign_attributes(:status => objekt["status"])
      objekts << qna
    end
    objekts.compact
  end

  def self.validate_objekts(objekts)
    error_rows = []
    objekts.each_with_index do |objekt, index|
      if objekt.invalid?
        error_message = objekt.errors.full_messages.join(", ")
        error_message = "receiver not present in panel or speaker" if error_message == "Receiver can't be blank"
        error_rows << "row#{index + 2} :   #{error_message}\n"
      end  
      Rails.logger.info objekt.errors.inspect
    end
    error_rows
  end

  def self.save_objekts(objekts)
    objekts.each do |objekt|
      objekt.save
    end
  end

end