class EdmMailSent < ActiveRecord::Base
  belongs_to :edm

  def Timestamp
    self.updated_at.in_time_zone('Mumbai')
  end

  def Campaign_Name
    if self.edm.present?
      self.edm.campaign.present? ? self.edm.campaign.campaign_name : ""      
    end
  end

  def eDM_Name
    self.edm.present? ? self.edm.subject_line : ""  
  end

  def number_sent
    EdmMailSent.where(:event_id => self.event_id,:edm_id => self.edm_id).count
  end

  def number_opened
    EdmMailSent.where(:event_id => self.event_id,:edm_id => self.edm_id,:open => "yes").count
  end

  def number_of_track_link_1_clicks
    TrackLink.get_count_for_export(self.event_id,self.edm_id)
    TrackLink.number_of_link_clicks(self.event_id,"track_link_1_id",self.edm_id)
  end
 
  def number_of_track_link_2_clicks
    TrackLink.get_count_for_export(self.event_id,self.edm_id)
    TrackLink.number_of_link_clicks(self.event_id, "track_link_2_id",self.edm_id)
  end
 
  def number_of_track_link_3_clicks
    TrackLink.get_count_for_export(self.event_id,self.edm_id)
    TrackLink.number_of_link_clicks(self.event_id,"track_link_3_id",self.edm_id)
  end

  def number_of_track_link_4_clicks
    TrackLink.get_count_for_export(self.event_id,self.edm_id)
    TrackLink.number_of_link_clicks(self.event_id, "track_link_4_id",self.edm_id)
  end
 
  def number_of_track_link_5_clicks
    TrackLink.get_count_for_export(self.event_id,self.edm_id)
    TrackLink.number_of_link_clicks(self.event_id,"track_link_5_id",self.edm_id)
  end

  def number_of_track_link_6_clicks
    TrackLink.get_count_for_export(self.event_id,self.edm_id)
    TrackLink.number_of_link_clicks(self.event_id,"track_link_6_id",self.edm_id)
  end

  def number_of_track_link_7_clicks
    TrackLink.get_count_for_export(self.event_id,self.edm_id)
    TrackLink.number_of_link_clicks(self.event_id,"track_link_7_id",self.edm_id)
  end

  def number_of_track_link_8_clicks
    TrackLink.get_count_for_export(self.event_id,self.edm_id)
    TrackLink.number_of_link_clicks(self.event_id,"track_link_8_id",self.edm_id)
  end

  def number_of_track_link_9_clicks
    TrackLink.get_count_for_export(self.event_id,self.edm_id)
    TrackLink.number_of_link_clicks(self.event_id,"track_link_9_id",self.edm_id)
  end

  def number_of_track_link_10_clicks
    TrackLink.get_count_for_export(self.event_id,self.edm_id)
    TrackLink.number_of_link_clicks(self.event_id,"track_link_10_id",self.edm_id)
  end
end