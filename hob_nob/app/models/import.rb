class Import < ActiveRecord::Base

  attr_accessor :event_id, :client_id

  has_attached_file :import_file, IMPORT_STORAGE
  has_attached_file :log_file, LOG_STORAGE

  # old entries are marked rejected from backend
  scope :not_rejected, -> { where.not(status: 'Rejected') }

  validates_attachment_presence :import_file,
                                message: 'This field is required.'
  validates_attachment_content_type :log_file, content_type: 'text/plain'
  validates_attachment_content_type :import_file,
                                    content_type: %w(application/zip application/msword application/vnd.ms-office application/vnd.ms-excel application/vnd.openxmlformats-officedocument.spreadsheetml.sheet application/xls application/xlsx application/octet-stream)

  default_scope { order('created_at desc') }

  def validation_errors_for_data(error_messages)
    self.errors.add(:import_file, error_messages.join("<br/>"))
  end

  def update_import(attributes)
    log = Tempfile.new(["log_#{id}", '.csv'])
    log.write(CSV.generate(headers: true) { |csv| attributes[:log_file].each { |row| csv << row } })
    attributes.delete(:log_file)
    update_attributes(attributes)
    log.rewind
    self.log_file = log
    self.save && log.close!
  end

  def update_row_count
    file_path = import_file.url.split("?").first
    if File.extname(file_path) == ".xlsx"
      workbook = Roo::Excelx.new(file_path)
    elsif File.extname(file_path) == ".xls"
      workbook = Roo::Excel.new(file_path)
    end

    begin
      Timeout.timeout(60) do
        update_attribute(:row_count, workbook.last_row-1)
      end
    rescue => e
      imp_attr = {
        log_file: [['Line No.', 'Row Data' , 'Status', 'Description'], ['1', 'row', 'error', 'File not supported']],
        status: 'Failed'
      }
      update_import(imp_attr)
    end
  end

end
