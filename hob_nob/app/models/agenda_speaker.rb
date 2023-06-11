class AgendaSpeaker < ActiveRecord::Base
  belongs_to :agenda
  
  validates :speaker_name, :uniqueness => true
end
