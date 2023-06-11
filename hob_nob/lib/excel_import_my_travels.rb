require 'rubygems'
require 'roo'
require 'open-uri'
# require 'zip/zipfilesystem'
#include ActiveSupport::Inflector

module ExcelImportMyTravel
#options => {:start_row => 'start_row_number'}
  def self.save(file_path, klass_name, event_id,attributes=[], operation='add', options={})
    attributes = MyTravel.column_names
    attributes -= ["id","created_at", "updated_at"]
    objekts = self.prepare_objekts(file_path, klass_name, event_id, attributes, operation, options)
    errors = ExcelImportMyTravel.validate_objekts(objekts)
    if errors.blank?
      ExcelImportMyTravel.save_objekts(objekts)
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
      invitee_id = event.invitees.find_by_email(objekt["invitee_email"]).id rescue nil
      my_travel = MyTravel.find_or_initialize_by(:event_id => event_id,:invitee_id => invitee_id)
      if objekt["file_1_url"].present?
        url1 = objekt["file_1_url"] rescue nil
        data = open(url1).read rescue nil
        if data.present?
          write_file_content = File.open("public/#{url1.split('/').last}", 'wb') do |f|
            f.write(data)
          end
          attach_file_1 = (File.open("public/#{url1.split('/').last}",'rb'))
          my_travel.attach_file = attach_file_1 
          my_travel.attach_file_1_name = objekt["file_name_1"]
        else
          my_travel.errors.add(:attach_file, "Incorrect URL")
        end
      end
      if objekt["file_2_url"].present?
        url2 = objekt["file_2_url"] rescue nil
        data = open(url2).read rescue nil
        if data.present?
          write_file_content = File.open("public/#{url2.split('/').last}", 'wb') do |f|
            f.write(data)
          end
          attach_file_2 = (File.open("public/#{url2.split('/').last}",'rb'))
          my_travel.attach_file_2 = attach_file_2 if attach_file_2.present?
          my_travel.attach_file_2_name = objekt["file_name_2"] if objekt["file_name_2"].present?
        else
          my_travel.errors.add(:attach_file_2, "Incorrect URL")
        end
      end
      if objekt["file_3_url"].present?
        url3 = objekt["file_3_url"] rescue nil
        data = open(url3).read rescue nil
        if data.present?
          write_file_content = File.open("public/#{url3.split('/').last}", 'wb') do |f|
            f.write(data)
          end
          attach_file_3 = (File.open("public/#{url3.split('/').last}",'rb'))
          my_travel.attach_file_3 = attach_file_3 if attach_file_3.present?
          my_travel.attach_file_3_name = objekt["file_name_3"] if objekt["file_name_3"].present?
        else
          my_travel.errors.add(:attach_file_3, "Incorrect URL")
        end
      end
      if objekt["file_4_url"].present?
        url4 = objekt["file_4_url"] rescue nil
        data = open(url4).read rescue nil
        if data.present?
          write_file_content = File.open("public/#{url4.split('/').last}", 'wb') do |f|
            f.write(data)
          end
          attach_file_4 = (File.open("public/#{url4.split('/').last}",'rb'))
          my_travel.attach_file_4 = attach_file_4 if attach_file_4.present?
          my_travel.attach_file_4_name = objekt["file_name_4"] if objekt["file_name_4"].present?
        else
          my_travel.errors.add(:attach_file_4, "Incorrect URL")
        end
      end
      if objekt["file_5_url"].present?
        url5 = objekt["file_5_url"] rescue nil
        data = open(url5).read rescue nil
        if data.present?
          write_file_content = File.open("public/#{url5.split('/').last}", 'wb') do |f|
            f.write(data)
          end
          attach_file_5 = (File.open("public/#{url5.split('/').last}",'rb'))
          my_travel.attach_file_5 = attach_file_5 if attach_file_5.present?
          my_travel.attach_file_5_name = objekt["file_name_5"] if objekt["file_name_5"].present?
        else
          my_travel.errors.add(:attach_file_5, "Incorrect URL")
        end
      end
      # my_travel = MyTravel.new(:event_id => event_id,:invitee_id => invitee_id,:attach_file => attach_file_1,:attach_file_1_name => objekt["file_name_1"],:attach_file_2 => attach_file_2,:attach_file_2_name => objekt["file_name_2"],:attach_file_3 => attach_file_3,:attach_file_3_name => objekt["file_name_3"],:attach_file_4 => attach_file_4,:attach_file_4_name => objekt["file_name_4"],:attach_file_5 => attach_file_5,:attach_file_5_name => objekt["file_name_5"])
      
      my_travel.comment_box = objekt["comment_box"]
      objekts << my_travel
      File.delete("public/#{url1.split('/').last}") if url1.present? and File.exist?("public/#{url1.split('/').last}")
      File.delete("public/#{url2.split('/').last}") if url2.present? and File.exist?("public/#{url2.split('/').last}")
      File.delete("public/#{url3.split('/').last}") if url3.present? and File.exist?("public/#{url3.split('/').last}")
      File.delete("public/#{url4.split('/').last}") if url4.present? and File.exist?("public/#{url4.split('/').last}")
      File.delete("public/#{url5.split('/').last}") if url5.present? and File.exist?("public/#{url5.split('/').last}")
    end
    objekts.compact
  end

  def self.validate_objekts(objekts)
    error_rows = []
    objekts.each_with_index do |objekt, index|
      if objekt.errors.present?
        error_message = objekt.errors.full_messages.join(", ")
        error_message = "File name This field is required., Attach file This field is required." if error_message.split(", ").include?("Attach file 1 name This field is required.") and error_message.split(", ").include?("Attach file This field is required.")
        error_message = "File name This field is required., " if error_message.split(", ").include?("Attach file 1 name This field is required.")
        error_rows << "row#{index + 2} :   #{objekt.errors.full_messages.join(", ")}\n"
      else
        error_rows << "row#{index + 2} :   #{objekt.errors.full_messages.join(", ")}\n" if objekt.invalid?
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