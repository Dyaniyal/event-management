class Document < ActiveRecord::Base

  belongs_to :resource, polymorphic: true

  delegate :client, to: :resource

  has_attached_file :document, DOCUMENT_FILE_PATH

  validates_attachment_content_type :document,
    content_type: [
                    'application/vnd.oasis.opendocument.formula-template', # .otf
                    'application/x-font-otf', # .otf
                    'application/x-font-ttf', # .ttf
                    'image/svg+xml', # .svg
                    'application/vnd.ms-fontobject', # .eot
                    'application/font-woff', # .woff
                    'application/octet-stream' # woff2
                  ],
    if: -> { resource_type == 'Font' }

end