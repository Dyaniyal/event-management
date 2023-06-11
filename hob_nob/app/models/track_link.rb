class TrackLink < ActiveRecord::Base
  belongs_to :event
  belongs_to :edm
  has_many :track_link_users, :dependent => :destroy
  after_save :get_regenrate_url

  def get_regenrate_url
    self.update_column(:regenerate_link ,"#{SAPP_URL}/admin/events/#{self.event_id}/track_links/#{self.id}?email=current_user")
  end

  def self.get_count_for_export(event_id,edm_id)
    edm = Edm.find_by_id(edm_id) if edm_id.present?
    arr = []
    arr << edm.track_link_1_id if edm.track_link_1_id.present?
    arr << edm.track_link_2_id if edm.track_link_2_id.present?
    arr << edm.track_link_3_id if edm.track_link_3_id.present?
    arr << edm.track_link_4_id if edm.track_link_4_id.present?
    arr << edm.track_link_5_id if edm.track_link_5_id.present?
    arr << edm.track_link_6_id if edm.track_link_6_id.present?
    arr << edm.track_link_7_id if edm.track_link_7_id.present?
    arr << edm.track_link_8_id if edm.track_link_8_id.present?
    arr << edm.track_link_9_id if edm.track_link_9_id.present?
    arr << edm.track_link_10_id if edm.track_link_10_id.present?
    edm_track_links = TrackLink.where('id IN (?)',arr)
    if edm_track_links.present?
      track_link_count = edm_track_links.pluck(:link_count).compact
      total_count = track_link_count.inject() { |sum, number| sum.to_i + number.to_i } if track_link_count.present?
    end
    total_count
  end
  
  def self.get_edm_count(edm_id, track_number)
    count = 0
    edm_track_links = TrackLink.where(:edm_id => edm_id, :track_link_no => track_number)
    if edm_track_links.present?
      track_link_count = edm_track_links.pluck(:link_count).compact
      count = track_link_count.inject() { |sum, number| sum.to_i + number.to_i } if track_link_count.present?
    end
    count
  end

  def track_user(email)
    track_link_user = TrackLinkUser.new( :email => email, :event_id => self.event_id,:track_link_id => self.id, :edm_id => self.edm_id,:track_link_no => self.track_link_no)
    track_link_user.save
  end

  def self.get_count(event_id, track_number)
    count = 0
    event_track_links = TrackLink.joins(:edm).where.not(edms: {campaign_id: 0}).where(event_id: event_id, track_link_no: track_number)
    if event_track_links.present?
      track_link_count = event_track_links.pluck(:link_count).compact
      count = track_link_count.inject() { |sum, number| sum.to_i + number.to_i } if track_link_count.present?
    end
    count
  end

  def self.number_of_link_clicks(event_id, track_number, edm_id)
    count = 0
    edm = Edm.find_by_id(edm_id) if edm_id.present?
    arr = []
    arr << edm.track_number if edm.track_number.present? 
    edm_track_links = TrackLink.where('id IN (?)',arr)
    if edm_track_links.present?
      track_link_count = edm_track_links.pluck(:link_count).compact
      count = track_link_count.inject() { |sum, number| sum.to_i + number.to_i } if track_link_count.present?
    end
    count
  end
end
