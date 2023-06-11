require 'rubygems'
require 'roo'
# require 'zip/zipfilesystem'
#include ActiveSupport::Inflector

## Remove the commented section after pushing the branch to master
module ExcelImportUnsubscribeData
#options => {:start_row => 'start_row_number'}
  def self.save(file_path, klass_name, event_id,attributes=[], operation='add', options={})
    attributes = Unsubscribe.column_names
    attributes -= ["id","event_id", "edm_id","created_at", "updated_at"]
    objekts = ExcelImportUnsubscribeData.prepare_objekts(file_path, klass_name, event_id, attributes, operation, options)
    # errors = ExcelImportUnsubscribeData.validate_objekts(objekts)
    # if errors.blank?
    #   ExcelImportUnsubscribeData.save_objekts(objekts)
    #   return {:is_saved => true}
    # else
    #   excel_errors = "Errors found at rows: #{errors.to_sentence}"
    #   return {:is_saved => false, :excel_errors => excel_errors}
    # end
  end

  # def self.update(file_path, klass_name, attributes=[], operation='add', options={})
  #   objekts = self.prepare_objekts(file_path, klass_name, attributes, operation, options)
  #   return {:is_saved => true}
  # end

  def self.prepare_objekts(file_path, klass_name, event_id, attributes, operation, options)
    # ENV['ROO_TMP'] = "#{Rails.root}/tmp"
    # ext = File.extname(file_path)
    # puts ext
    # workbook = nil
    if File.extname(file_path) == ".xlsx"
      workbook = Roo::Excelx.new(file_path)
    elsif File.extname(file_path) == ".xls"
      workbook = Roo::Excel.new(file_path)
    end
    # start_row = options[:start_row] || 1
    # objekts = []
    # columns_in_worksheet = []
    workbook.default_sheet = workbook.sheets.first
    # 0.upto(workbook.last_column) do |col|
    #   columns_in_worksheet << workbook.cell(workbook.first_row, col)
    # end
    # columns_in_worksheet.compact!
    # letters_array = [*('A').upto('AZ')]

    if workbook.first_column.blank?
      return {is_saved: false, excel_errors: 'Contains no rows'} 
    else
      workbook.column(1)[1..-1].each do |email|
        unsubscribe = Unsubscribe.find_or_initialize_by(email: email.to_s.strip, event_id: event_id)
        unsubscribe.unsubscribe = 'true'
        unsubscribe.save
      end
    end
    # start_row.upto(workbook.last_row) do |line|
    #   objekt = {} #klass_name.classify.constantize.new()
      
    #   columns_in_worksheet.each_with_index do |attrib, index|
    #     objekt[attrib.parameterize('_').strip] = workbook.cell(line, letters_array[index]).strip rescue ''
    #   end

    #   # if unsubscribe.present?
    #   #   objekts << unsubscribe
    #   # end
    # end
    # objekts.compact
    return {:is_saved => true}
  end

  # def self.validate_objekts(objekts)
  #   error_rows = []
  #   objekts.each_with_index do |objekt, index|
  #     error_rows << "row#{index + 2} :   #{objekt.errors.full_messages.join(", ")}\n" if objekt.invalid?
  #     Rails.logger.info objekt.errors.inspect
  #   end
  #   error_rows
  # end

  # def self.save_objekts(objekts)
  #   objekts.each do |objekt|
  #     objekt.unsubscribe = "true"
  #     objekt.save
  #   end
  # end

end