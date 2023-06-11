class Font < ActiveRecord::Base

  attr_accessor :document1, :document2, :document3, :document4, :document5, :document6

  DEFAULT_FONTS = [['Sans Serif','micross'],['Serif','AbhayaLibre-Regular'],['Fixed Width','LiberationMono-Regular'],['Garamond','EBGaramond-Regular'],['Georgia','Georgia'],['Tahoma','Tahoma'],['Verdana','Verdana']]

  has_many :documents, as: :resource, dependent: :destroy

  belongs_to :client

  validates :font_name, presence: true

  validate :validate_font_documents
  validate :validate_font_name

  accepts_nested_attributes_for :documents, reject_if: :all_blank, allow_destroy: true

  after_create :store_font_files

  def font_hash
    formatt = { 'otf' => 'opentype', 'eot' => 'embedded-opentype', 'ttf' => 'truetype' }
    documents.map do |doc|
      ext = doc.document_file_name.split('.').last
      f = formatt.include?(ext) ? formatt[ext] : ext
      {
        font_name: font_name,
        url: [
               "#{SAPP_URL}/custom_fonts/client_#{client_id}/#{doc.document_file_name}",
               "#{APP_URL}/custom_fonts/client_#{client_id}/#{doc.document_file_name}"
             ],
        format: f
      }
    end
  end

  def document_files
    documents.map(&:document_file_name)
  end

  private

  def validate_font_name
    errors.add(:font_name, 'This client already have font with same name') if client.fonts.where(font_name: font_name).present?
    errors.add(:font_name, 'Already present in default font list') if DEFAULT_FONTS.map { |x| x[0] }.include?(font_name)
  end

  def validate_font_documents
    repeated = document_files.detect{ |e| document_files.count(e) > 1 }
    ext = document_files.map { |fn| fn.split('.').last }
    repeated_ext = ext.detect{ |e| ext.count(e) > 1 }
    if documents.blank?
      errors.add(:base, 'At least one font file is needed')
    elsif (repeated.present? || repeated_ext.present?)
      errors.add(:base, "Font can have single #{repeated || '.' + repeated_ext + ' File'}")
    else
      fonts = client.fonts.includes(:documents)
      document_files.each do |doc_name|
        existing = fonts.where(documents: { document_file_name: doc_name })[0].try(:font_name)
        errors.add(:base, "#{existing} already contain #{doc_name}") if existing
      end
    end
  end

  def store_font_files
    dir = "#{Rails.root}/public/custom_fonts/client_#{client_id}"
    FileUtils.mkdir(dir) unless File.directory? dir
    documents.each { |doc| doc.document.copy_to_local_file(nil, "#{dir}/#{doc.document_file_name}") }
  end

end
