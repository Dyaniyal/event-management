require 'rubygems'
require 'roo'
# require 'zip/zipfilesystem'
#include ActiveSupport::Inflector

module ExcelImportAgenda
#options => {:start_row => 'start_row_number'}
  def self.save(file_path, klass_name, event_id,attributes=[], operation='add', options={})
    attributes = Agenda.column_names
    attributes -= ["id","event_id","created_at", "updated_at"]
    objekts = self.prepare_objekts(file_path, klass_name, event_id, attributes, operation, options)
    errors = ExcelImportAgenda.validate_objekts(objekts)
    if errors.blank?
      ExcelImportAgenda.save_objekts(objekts)
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

      # speakers = Speaker.where("event_id =?", event_id) if event_id.present?
      # speaker_id = speakers.find_by_speaker_name(objekt['speaker']).id rescue ""

      columns_in_worksheet.each_with_index do |attrib, index|
        # objekt[attrib.parameterize('_').strip] = workbook.cell(line, letters_array[index]).strip rescue ''
        objekt[attrib.parameterize('_').strip] = workbook.cell(line, letters_array[index]).is_a?(String) ? (workbook.cell(line, letters_array[index]).strip rescue '') : (workbook.cell(line, letters_array[index]))
      end
      agenda = Agenda.new
      # if objekt["track"].present?
      #   agendas = Agenda.where(event_id: event_id ,start_agenda_date: objekt['start_date_dd_mm_yyyy'].to_date)
      #   sequence = 1
      #   if agendas.present?
      #     agenda_tack_ids = agendas.pluck(:agenda_track_id).compact
      #     if agenda_tack_ids.present?
      #       agenda_tracks = AgendaTrack.where("id IN (?)",agenda_tack_ids).pluck(:sequence).compact
      #       sequence = agenda_tracks.max + 1 if agenda_tracks.present?
      #     end
      #   end
      #   agenda_track = AgendaTrack.find_or_initialize_by(track_name: objekt["track"], event_id: event_id,agenda_date: objekt['start_date_dd_mm_yyyy'].to_date)
      #   agenda_track.sequence = sequence if agenda_track.new_record?
      #   agenda_track.save
      # end
      # agenda_track_id = agenda_track.present? ? agenda_track.id : nil
      agenda.assign_attributes(:event_id => event_id,:title => objekt['title'],:speaker_name => objekt['speaker'], :start_agenda_date => objekt['start_date_dd_mm_yyyy'], :start_time_hour => objekt["start_time_hour"],:start_time_minute => objekt["start_time_minute"],:start_time_am => objekt["start_time_am_pm"], :end_agenda_date => objekt["end_date_dd_mm_yyyy"],:end_time_hour => objekt["end_time_hour"],:end_time_minute => objekt["end_time_minute"],:end_time_am => objekt["end_time_am_pm"], :discription => objekt["description"], :rating_status => objekt["session_rating"], :agenda_track_name_import => objekt["track"])
      objekts << agenda
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

  # def self.save_objekts(objekts)
  #   objekts.each do |objekt|
  #     objekt.save
  #   end
  # end
  def self.save_objekts(objekts)
    objekts.each do |objekt|
      track_name = objekt.agenda_track_name_import
      objekt.save
      agenda_track = ExcelImportAgenda.assign_agenda_track(objekt,track_name)
      objekt.update_column('agenda_track_id',agenda_track.id) if agenda_track.present?
    end
  end
  
  def self.assign_agenda_track(objekt,track_name)
    if track_name.present?
      agendas = Agenda.where(event_id: objekt.event_id ,start_agenda_date: objekt.start_agenda_date.to_date)
      sequence = 1
      if agendas.present?
        agenda_tack_ids = agendas.pluck(:agenda_track_id).compact
        if agenda_tack_ids.present?
          agenda_tracks = AgendaTrack.where("id IN (?)",agenda_tack_ids).pluck(:sequence).compact
          sequence = agenda_tracks.max + 1 if agenda_tracks.present?
        end
      end
      agenda_track = AgendaTrack.find_or_initialize_by(track_name: track_name, event_id: objekt.event_id,agenda_date: objekt.start_agenda_date.to_date)
      agenda_track.sequence = sequence if agenda_track.new_record?
      agenda_track.save
      agenda_track      
    end
  end

end