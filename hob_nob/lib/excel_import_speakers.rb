require 'rubygems'
require 'roo'
require 'open-uri'
# require 'zip/zipfilesystem'
#include ActiveSupport::Inflector

module ExcelImportSpeaker
#options => {:start_row => 'start_row_number'}
  def self.save(file_path, klass_name, event_id,attributes=[], operation='add', options={})
    attributes = Speaker.column_names
    attributes -= ["id","event_id","created_at", "updated_at"]
    objekts = self.prepare_objekts(file_path, klass_name, event_id, attributes, operation, options)
    errors = ExcelImportSpeaker.validate_objekts(objekts)
    if errors.blank?
      ExcelImportSpeaker.save_objekts(objekts)
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
        # objekt[attrib.parameterize('_').strip] = workbook.cell(line, letters_array[index]).strip rescue ''
        objekt[attrib.parameterize('_').strip] = workbook.cell(line, letters_array[index]).is_a?(Numeric) ? (workbook.cell(line, letters_array[index]).to_s.strip rescue '') : (workbook.cell(line, letters_array[index]).strip rescue '')
      end
      email = objekt['email_address'].downcase rescue nil
      speaker = Speaker.find_or_initialize_by(:email_address => email, :event_id => event_id)
      if objekt["profile_picture"].present?
        profile_url = objekt["profile_picture"] rescue nil
        data = open(profile_url).read rescue nil
        if data.present?
          write_file_content = File.open("public/#{profile_url.split('/').last}", 'wb') do |f|
            f.write(data)
          end
          profile_picture = (File.open("public/#{profile_url.split('/').last}",'rb'))
          speaker.profile_pic = profile_picture
        else
          speaker.errors.add(:profile_pic, "Incorrect URL")
        end
      end
      speaker.assign_attributes(:first_name => objekt['first_name'], :last_name => objekt['last_name'],:company => objekt['company'], :designation => objekt['designation'], :phone_no => objekt["phone_no"],:speaker_info => objekt['speaker_bio'], :twitter_id => objekt['twitter_link'], :linkedin_id => objekt['linkedin_link'], :facebook_id => objekt['facebook_link'], :google_id => objekt['google_link'], :rating_status => objekt['rating'],:event_id => event_id)
      objekts << speaker
      File.delete("public/#{profile_url.split('/').last}") if profile_url.present? and File.exist?("public/#{profile_url.split('/').last}")
    end
    objekts.compact
  end

  def self.validate_objekts(objekts)
    error_rows = []
    objekts.each_with_index do |objekt, index|
      if objekt.errors.present?
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