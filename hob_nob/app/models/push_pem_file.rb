class PushPemFile < ActiveRecord::Base

  belongs_to :mobile_application

  validates :mobile_application_id, :android_push_key, presence: { message: 'This field is required.' }

  default_scope { order('created_at desc') }

end