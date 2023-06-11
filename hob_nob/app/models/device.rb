class Device < ActiveRecord::Base
  belongs_to :user
  belongs_to :invitee, :class_name => 'Invitee', :foreign_key => 'email', :primary_key => 'email'

  validates :token, :platform,:mobile_application_id, presence: true
  # validates :token, :platform, :invitee_id,:mobile_application_id,:email, presence: true
  #validates_uniqueness_of :token, :scope => [:user_id, :platform]
  # validates_uniqueness_of :token, :scope => [:invitee_id, :platform]

end