class AgendaTrack < ActiveRecord::Base
  

  require 'set_mult_lng_data'
#  validates :track_name, :uniqueness => {:scope => [:agenda_date]}
  validates :track_name, presence: true
  validates :event_id, presence: true
  validates_uniqueness_of :track_name, :scope => [:agenda_date, :event_id]
  belongs_to :event
  has_many :agendas, :dependent => :destroy
  after_create :update_multi_lng_model_data 
  after_save :save_agendas
  
  def update_multi_lng_model_data
    if self.parent_id.blank?
      SetMultLngData.set_model_details(self)
    end 
  end
  def save_agendas
    for agenda in self.agendas
      agenda.update_column(:updated_at, Time.now.in_time_zone("UTC"))
      agenda.update_last_updated_model
      agenda.clear_cache
    end 
  end 

  def self.set_agenda_track(params)
    agendas = Agenda.where(event_id: params[:event_id],start_agenda_date: params[:agenda][:start_agenda_date].to_date)
    if agendas.present?
    	agenda_tack_ids = agendas.pluck(:agenda_track_id).compact
    	if agenda_tack_ids.present?
    		agenda_tracks = AgendaTrack.where("id IN (?)",agenda_tack_ids).pluck(:sequence).compact
    	  agenda_tracks.present? ? (sequence = agenda_tracks.max + 1) : ((sequence = 1)) 
      else
    		sequence = 1		
    	end
    else
    	sequence = 1	
    end
    if params[:agenda][:agenda_track_id].present? || params[:agenda][:new_category].present? 
      if params[:agenda][:agenda_track_id].present? and params[:agenda][:agenda_track_id] == '0'
        @agenda_track = AgendaTrack.find_or_initialize_by(track_name: params[:agenda][:new_category].strip, event_id: params[:agenda][:event_id],agenda_date: params[:agenda][:start_agenda_date].to_date)
      else
        @agenda_track = AgendaTrack.find_or_initialize_by(track_name: params[:agenda][:agenda_track_id].strip, event_id: params[:agenda][:event_id],agenda_date: params[:agenda][:start_agenda_date].to_date)
      end  
      @agenda_track.sequence = sequence if @agenda_track.new_record?
      @agenda_track.save
      @agenda_track
    end  
	end	
end
