class Rating < ActiveRecord::Base

	attr_accessor :platform
  belongs_to :ratable, :polymorphic => true#, :counter_cache => :ratings_count_cache
  belongs_to :user, :class_name => 'Invitee', :foreign_key => 'rated_by'

	validates :rated_by, :ratable_id, :ratable_type, presence: true#, :rating#, :out_of, :comments
  validate :validate_either_rating_or_comments
  before_create :set_parent_id_multilingual
  after_create :create_analytic_record
  default_scope { order('created_at desc') }

  def set_parent_id_multilingual
    if self.ratable.present? and self.ratable.parent_id.present?
      self.ratable_id = self.ratable.parent_id
    end
  end  

  def validate_either_rating_or_comments
    if self.rating.blank? and self.comments.blank?
      errors.add(:rating, "Give either rating or comments") if self.rating.blank?
      errors.add(:comments, "Give either rating or comments") if self.comments.blank?
    end
  end

	def get_user_name
		Invitee.find_by_id(self.rated_by).name_of_the_invitee rescue nil
	end

  def star_rating
    self.rating
  end

  def Timestamp
    # self.created_at.in_time_zone(self.ratable.event_timezone).strftime("%d/%m/%Y %T")
    (self.created_at + self.ratable.event.timezone_offset.to_i.seconds).strftime("%d/%m/%Y %T")
  end

  def email_id
    self.user.email rescue ""
  end

  def name
    Invitee.find_by_id(self.rated_by).name_of_the_invitee rescue ""
  end

  def first_name
    Invitee.find_by_id(self.rated_by).first_name rescue ""
  end

  def last_name
    Invitee.find_by_id(self.rated_by).last_name rescue ""
  end

  def user_rating
    self.rating rescue ""
  end

  def user_comment
    self.comments rescue ""
  end

  def twitter_link
    self.twitter_id rescue ""
  end

  def linkedin_link
    self.linkedin_id rescue ""
  end
 
  def facebook_link
    self.facebook_id rescue ""
  end

  def google_link
    self.google_id rescue ""
  end

  def session_name
    if self.ratable_type == 'Agenda'
      self.ratable.title rescue ""
    end
  end
  
  def speaker_name
    if self.ratable_type == 'Agenda'
      return self.ratable.all_speaker_names
    end
    if self.ratable_type == "Speaker"
      return self.ratable.speaker_name rescue ""
    end  
  end

  def self.get_top_three_speaker_ids(event_id, start_date=nil, to_date=nil)
    start_date = start_date.blank? ? Date.today : start_date.to_date
    to_date = to_date.blank? ? Date.today : to_date.to_date
    speaker_ids = Speaker.where(:event_id => event_id).pluck(:id)
    # arr = Rating.where('ratable_type = ? and ratable_id IN (?) and Date(created_at) >= ? and Date(created_at) <= ?', 'Speaker', speaker_ids, start_date, to_date).group(:ratable_id).count.sort_by{|k, v| v}.last(3).map{|a| a[0]}.compact
    ratings = Rating.where('ratable_type = ? and ratable_id IN (?)', 'Speaker', speaker_ids).group_by(&:ratable_id)#.count.sort_by{|k, v| v}.last(3).map{|a| a[0]}.compact
    arr = ratings.map{|k, v| [k, v.map{|a| a.rating}.sum / v.count]}.sort_by{|k| k[1]}.last(3)
    arr.reverse
  end

  def self.get_top_rated(return_count, event_id, type, start_date, to_date)
    start_date = start_date.blank? ? Date.today : start_date.to_date
    to_date = to_date.blank? ? Date.today : to_date.to_date
    ratable_ids = Speaker.where(:event_id => event_id).pluck(:id) if type == 'Speaker'
    ratable_ids = Agenda.where(:event_id => event_id).pluck(:id) if type == 'Agenda'
    ratable_ids = Sponsor.where(:event_id => event_id).pluck(:id) if type == 'Sponsor'
    ratings = Rating.where('ratable_type = ? and ratable_id IN (?) and Date(created_at) >= ? and Date(created_at) <= ?', type, ratable_ids, start_date, to_date).group_by(&:ratable_id)#.count.sort_by{|k, v| v}.last(3).map{|a| a[0]}.compact
    arr = ratings.map{|k, v| [k, v.map{|a| a.rating}.sum / v.count]}.sort_by{|k| k[1]}.last(return_count)
    arr.reverse
  end

  def create_analytic_record
    event_id = Invitee.find_by_id(self.rated_by).event_id rescue nil
    analytic = Analytic.new(viewable_type: self.ratable_type, viewable_id: self.ratable_id, action: "rated", invitee_id: self.rated_by, event_id: event_id, platform: platform)
    analytic.save rescue nil
  end
end
