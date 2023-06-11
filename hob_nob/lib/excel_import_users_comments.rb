require 'rubygems'
require 'roo'
# require 'zip/zipfilesystem'
#include ActiveSupport::Inflector

module ExcelImportUserComment
#options => {:start_row => 'start_row_number'}
  def self.save(file_path, klass_name, event_id,attributes=[], operation='add', options={})
    attributes = Comment.column_names
    attributes -= ["id","created_at", "updated_at"]
    objekts = ExcelImportUserComment.prepare_objekts(file_path, klass_name, event_id, attributes, operation, options)
    errors = ExcelImportUserComment.validate_objekts(objekts)
    if errors.blank?
      ExcelImportUserComment.save_objekts(objekts)
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
      conversation_id = Conversation.where(:event_id => event_id, :description => objekt["conversation"]).first.id rescue nil
      user_id = Invitee.where(email: objekt['email'], event_id: event_id).first.id rescue nil
      comment = Comment.new(:user_id => user_id, :commentable_id => conversation_id, :commentable_type => 'Conversation', :description => objekt['comment'])
      objekts << comment
    end
    objekts.compact
  end

  def self.validate_objekts(objekts)
    error_rows = []
    objekts.each_with_index do |objekt, index|
      error_rows << "row#{index + 2} :   #{objekt.errors.full_messages.join(", ")}\n" if objekt.invalid?
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