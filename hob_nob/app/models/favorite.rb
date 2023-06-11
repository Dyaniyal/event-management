class Favorite < ActiveRecord::Base

	attr_accessor :platform
  belongs_to :event
  belongs_to :favoritable, polymorphic: true
  validates :invitee_id, :favoritable_type, :favoritable_id, :event_id, presence: true
  validates_uniqueness_of :invitee_id, :scope => [:favoritable_type, :favoritable_id]
  before_create :set_parent_id_multilingual
  after_create :create_analytic_record
  default_scope { order('created_at desc') }

  
  def set_parent_id_multilingual
    if self.event.parent_id.present?
      self.event_id = self.event.parent_id
    end
  end  

  def image_url(style=:large)
    # binding.pry
    if self.favoritable_type == "Image"
      style.present? ? self.favoritable.image.url(style) : self.favoritable.image.url rescue nil
    end
  end

  def create_analytic_record
    event_id = Invitee.find_by_id(self.invitee_id).event_id rescue nil
    analytic = Analytic.new(viewable_type: self.favoritable_type, viewable_id: self.favoritable_id, action: "favorite", invitee_id: self.invitee_id, event_id: event_id, platform: platform)
    analytic.save
  end

  def qr_code_analytics(platform)
    event_id = Invitee.find_by_id(self.invitee_id).event_id rescue nil
    analytic = Analytic.new(viewable_type: self.favoritable_type, viewable_id: self.favoritable_id, action: "qr code scan", invitee_id: self.invitee_id, event_id: event_id, platform: platform)
    analytic.save rescue nil
  end

  def self.get_top_favorite(count, type, event_id, from_date, to_date)
    favorites = Favorite.where('favoritable_type IN (?) and event_id = ? and Date(created_at) >= ? and Date(created_at) <= ?', type, event_id, from_date, to_date)
    favorites.group(:favoritable_id).count.sort_by{|k, v| v}.last(count).reverse
  end
end
