class SmtpSetting < ActiveRecord::Base
  attr_accessor :smtp_url
  belongs_to :user
  belongs_to :event
  validates :username, :password, :domain, :address, :port, :from_email, presence: { :message => "This field is required." }#, uniqueness: {scope: :user_id}
  validates :username, :password, presence: { :message => "This field is required." }#, uniqueness: {scope: :user_id}

  default_scope { order('created_at desc') }

  before_validation :update_port_number

  def update_port_number
    self.port = 587 if self.port.blank?
  end

end