require 'rubygems'
require 'roo'
# require 'zip/zipfilesystem'
#include ActiveSupport::Inflector

module ExcelEventuser
#options => {:start_row => 'start_row_number'}
  def self.save(file_path, klass_name,attributes=[], operation='add', options={})
    # attributes = Faq.column_names
    # attributes -= ["id","question","answer","event_id","user_id","sequence","created_at", "updated_at"]
    objekts = self.prepare_objekts(file_path, klass_name, attributes, operation, options)
    # errors = ExcelEventuser.validate_objekts(objekts)
    errors = nil
    if errors.blank?
      ExcelEventuser.save_objekts(objekts)
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

  def self.prepare_objekts(file_path, klass_name, attributes, operation, options)
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
      user_email = workbook.cell(line, letters_array[0])
      event_id = workbook.cell(line, letters_array[1])
      @user = User.find_by_email(user_email)
      @event = Event.find(event_id)
      delete_user = @event.users.exists?(:id => @user.id) rescue nil
      @event.users.delete(User.find(@user.id)) if delete_user == true
      
      if @user.present? and @event.present?

        if objekt.blank?
          objekt = [@event, @user]
        end
        objekts << objekt
      end
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
      event_id = objekt.first.id
      user_id = objekt.last.id
      @event = Event.find(event_id)
      user = User.find(user_id)
      @event.users << user
    end
  end

end