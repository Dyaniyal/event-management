class Conversation < ActiveRecord::Base

  include AASM
  attr_accessor :platform
  @@auto_approve = nil
  belongs_to :event
  belongs_to :user
  belongs_to :user, :class_name => 'Invitee', :foreign_key => 'user_id'
  has_many :comments, as: :commentable, :dependent => :destroy
  has_many :likes, as: :likable, :dependent => :destroy
  has_many :favorites, as: :favoritable, :dependent => :destroy
  belongs_to :user, :class_name => 'Invitee', :foreign_key => 'user_id'

  has_attached_file :image, {:styles => {:large => "640x640>",
                                         :small => "200x200>", 
                                         :thumb => "60x60>"},
                             :convert_options => {:large => "-strip -quality 90", 
                                         :small => "-strip -quality 80", 
                                         :thumb => "-strip -quality 80"}
                                         }.merge(CONVERSATION_IMAGE_PATH)
  
  validates_attachment_content_type :image, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"],:message => "please select valid format."
  validates :description, presence: { :message => "This field is required." }
  # validate :check_image_and_description
  validates :event_id, :user_id, presence: { :message => "This field is required." }

  before_create :set_parent_id_multilingual
  after_create :set_status_as_per_auto_approve, :create_analytic_record, :set_event_timezone#, :set_dates_with_event_timezone
  after_save :update_last_updated_model, :set_last_interaction_at, :update_analytics, :update_log_changes_when_reject
  before_save :rename_image_file_name
  scope :desc_ordered, -> { order('updated_at DESC') }
  scope :asc_ordered, -> { order('updated_at ASC') }

  aasm :column => :status do
    state :pending, :initial => true
    state :approved
    state :rejected
    
    event :approve, :after => [:update_analytics] do
      transitions :from => [:pending,:rejected], :to => [:approved]
    end 
    event :reject, :after => [:update_analytics]  do
      transitions :from => [:pending,:approved], :to => [:rejected]
    end 
  end

  def set_parent_id_multilingual
    if self.event.present? and self.event.parent_id.present?
      self.event_id = self.event.parent_id 
    end
  end  

  def update_analytics
    if self.status == "rejected"
      Analytic.where(:viewable_id => self.id, :viewable_type => "Conversation").each{|a| a.update_column("status", "rejected")}
    elsif self.status == "approved"
      Analytic.where(:viewable_id => self.id, :viewable_type => "Conversation").each{|a| a.update_column("status", "")}
    end
  end

  def update_log_changes_when_reject
    if self.status == "rejected"
      LogChange.create(:resourse_type => "Conversation", :resourse_id => self.id, :action => "destroy")
    elsif self.status == "approved"
      log_changes = LogChange.where(:resourse_type => "conversation", :resourse_id => self.id, :action => "destroy")
      log_changes.destroy_all
    end
  end

  def update_last_updated_model
    LastUpdatedModel.update_record(self.class.name)
  end

  def set_last_interaction_at
    self.update_column("last_interaction_at",Time.now)
  end

  def perform_conversation(conversation)
    if conversation == "approve"
      self.approve!
    elsif conversation == "pending"
      self.pending!
    elsif conversation == "reject"
      self.reject!
    end
  end
  
  def check_image_and_description
    if self.image.blank? and self.description.blank?
      self.error.add :description, 'You need to pass atleast one description or image'
    else
      return false
    end
  end

  def image_url(style=:large)
    if self.parent_id.present? and not self.image.exists?
      parent = Conversation.find(self.parent_id)
      url = style.present? ? parent.image.url(style) : parent.image.url
    else
      url = style.present? ? self.image.url(style) : self.image.url
    end
    url = "" if url == "/images/large/missing.png"
    url
  end

  def self.search(params,conversations)
    keyword = params[:search][:keyword]
    conversations = conversations.where("description like (?) ", "%#{keyword}%") if keyword.present?
    conversations
  end 

  def share_count
    Rails.cache.fetch("invitee_share_count_#{self.id}") { share_count! }
  end

  def share_count!
    Analytic.where(:viewable_id => self.id, :viewable_type => "Conversation", action: "share").length rescue 0
  end

  def like_count
    # Like.where(:likable_id => self.id, :likable_type => "Conversation").length rescue 0
    self.likes_count_cache.to_i
  end
  
  def comment_count
    # Comment.where(:commentable_id => self.id, :commentable_type => "Conversation").length rescue 0
    self.comments_count_cache.to_i
  end

  def user_name
    Rails.cache.fetch("invitee_user_name_#{self.user_id}") { user_name! }
  end

  def user_name!
    Invitee.find_by_id(self.user_id).name_of_the_invitee rescue ""
  end

  def get_company_name
    Rails.cache.fetch("invitee_get_company_name_#{self.user_id}") { get_company_name! }
  end

  def get_company_name!
    Invitee.find_by_id(self.user_id).company_name rescue ""
  end

  def company_name
    Rails.cache.fetch("invitee_company_name_#{self.user_id}") { company_name! }
  end

  def company_name!
    Invitee.find_by_id(self.user_id).company_name rescue ""
  end

  def invitee_email
    Rails.cache.fetch("invitee_invitee_email_#{self.user_id}") { invitee_email! }
  end

  def invitee_email!
    Invitee.find_by_id(self.user_id).email rescue nil
  end

  def timestamp
    # self.created_at.in_time_zone(self.event_timezone).strftime('%m/%d/%Y %H:%M')
    (self.created_at + self.event_timezone_offset.to_i.seconds).strftime('%m/%d/%Y %H:%M')
  end

  # def likes
  #   likes = Like.where(:likable_id => self.id, :likable_type => "Conversation") rescue nil
  #   user_ids = likes.pluck(:user_id) rescue nil
  #   user_names = Invitee.where(:id => user_ids).pluck(:name_of_the_invitee) rescue nil
  #   user_names.join(",") rescue nil
  # end

  def user_comments
    comments = Comment.where(:commentable_id => self.id, :commentable_type => "Conversation")
    str = ""
    comments.each do |comment|
      user_name = Invitee.where(:id => comment.user_id).first.name_of_the_invitee rescue nil
      desc = comment.description if user_name.present?
      str += "#{user_name} => #{desc}" + ' ~ ' 
    end
    str
  end

  def set_status_as_per_auto_approve
    if [17333, 58516, 57676, 55234, 58097, 55191, 55379, 57679, 55237, 56199, 55748, 57624, 58173, 56378, 55379, 55799, 59930, 55654, 59200, 59205, 55294, 58713, 56040, 58746, 60437, 63553, 63756, 64216, 67677, 68070].include? self.user_id
      self.update_column(:status, "rejected")
      self.update_analytics
    elsif Event.find(self.event_id).conversation_auto_approve == "true"
      self.update_column(:status, "approved") 
    elsif Event.find(self.event_id).conversation_auto_approve == "false"
      self.update_column(:status, "pending")
    end
  end

  def self.set_auto_approve(value,event)
    event.update_column(:conversation_auto_approve, value)
  end

  def create_analytic_record
    analytic = Analytic.new(viewable_type: "Conversation", viewable_id: self.id, action: "conversation post", invitee_id: self.user_id, event_id: self.event_id, platform: platform)
    analytic.save rescue nil
  end

  def set_event_timezone
    event = self.event
    self.update_column("event_timezone", event.timezone)
    self.update_column("event_timezone_offset", event.timezone_offset)
    self.update_column("event_display_time_zone", event.display_time_zone)
  end

  def set_dates_with_event_timezone
    event = self.event
    # self.update_column("created_at_with_event_timezone", self.created_at.in_time_zone(event.timezone))
    # self.update_column("updated_at_with_event_timezone", self.updated_at.in_time_zone(event.timezone))    
  end  

  def self.get_export_object(conversations)
    object = []
    conversation_without_comment = []
    comments = []
    conversations.each do |conversation|
      if conversation.comments.present?
        comments << conversation.comments
      else
        conversation_without_comment << conversation 
      end
    end if conversations.present?
    comment_obj = []
    # binding.pry
    comments.each do |comment|
      comment_obj << comment
    end if comments.present?
    object = object + comment_obj + conversation_without_comment
    object
  end

  def self.get_conversations_by_status(conversations, type)
    if type == "pending"
      conversations.where(:status => "pending")
    elsif type == "approved"
      conversations.where(:status => "approved")
    elsif type == "rejected"
      conversations.where(:status => "rejected")
    end
  end

  def conversation
    self.description.strip rescue ""
  end

  #use for conversation export remove blank values
  def commented_user_name
    ""
    # comment_by = self.comments.pluck(:user_id)
    # name_of_the_invitee = Invitee.find_by_id(comment_by).name_of_the_invitee
    # return name_of_the_invitee
    # binding.pry
  end

  def commented_user_email
    ""
    # comment_by = self.comments.pluck(:user_id)
    # email = Invitee.find_by_id(comment_by).email
    # return email
  end

  def email
    Rails.cache.fetch("invitee_email_#{self.user_id}") { email! }
  end

  def email!
    Invitee.find_by_id(self.user_id).email rescue ""
  end

  def email_id
    Invitee.find_by_id(self.user_id).email rescue ""
  end

  def name
    Rails.cache.fetch("invitee_name_#{self.user_id}") { name! }
  end

  def name!    
    Invitee.find_by_id(self.user_id).name_of_the_invitee rescue ""
  end
  
  def first_name
    Rails.cache.fetch("invitee_first_name_#{self.user_id}") { first_name! }
  end

  def first_name!
    Invitee.find_by_id(self.user_id).first_name rescue ""
  end

  def invitee_first_name
    Invitee.find_by_id(self.user_id).first_name rescue ""
  end

  def profile_pic_url
    Rails.cache.fetch("invitee_profile_pic_url_#{self.user_id}") { profile_pic_url! }
  end
  
  def profile_pic_url!
    Invitee.find_by_id(self.user_id).profile_pic.url(:large) rescue ""
  end
  
  def last_name
    Rails.cache.fetch("invitee_last_name_#{self.user_id}") { last_name! }
  end

  def last_name!
    Invitee.find_by_id(self.user_id).last_name rescue ""
  end

  def invitee_last_name
    Invitee.find_by_id(self.user_id).last_name rescue ""
  end

  def comment
    ""
  end
  def Status
    self.status rescue ""
  end

  def post_id
    self.id
  end

  def created_at_with_event_timezone
    # self.created_at.in_time_zone(self.event_timezone)
    self.created_at + self.event_timezone_offset.to_i.seconds
  end

  def updated_at_with_event_timezone
    # self.updated_at.in_time_zone(self.event_timezone)
    self.updated_at + self.event_timezone_offset.to_i.seconds
  end

  def formatted_created_at_with_event_timezone
    # self.created_at_with_event_timezone.strftime("%b %d at %I:%M %p (GMT %:z)")
    # created_at_with_tmz = self.created_at_with_event_timezone.strftime("%Y %b %d at %l:%M %p (GMT %:z)")
    created_at_with_tmz = self.created_at_with_event_timezone.strftime("%Y %b %d at %l:%M %p (#{self.event_display_time_zone})")
    year = Time.now.strftime("%Y") + " "
    created_at_with_tmz.sub(year, "")
  end

  def formatted_updated_at_with_event_timezone
    # self.updated_at_with_event_timezone.strftime("%b %d at %I:%M %p (GMT %:z)")
    # updated_at_with_tmz = self.updated_at_with_event_timezone.strftime("%Y %b %d at %l:%M %p (#{self.event.display_time_zone})")
    updated_at_with_tmz = self.updated_at_with_event_timezone.strftime("%Y %b %d at %l:%M %p (#{self.event_display_time_zone})")
    year = Time.now.strftime("%Y") + " "
    updated_at_with_tmz.sub(year, "")    
  end

  def self.get_approved_conversation(id)
    self.unscoped.where("id = ? and status = ?", id, "approved").last
  end

  def rename_image_file_name
    if (self.image_updated_at_changed? and self.image_file_name.present?)
      extension = File.extname(image_file_name).downcase
      self.image_file_name = "#{Time.now.to_i.to_s}#{extension}"
    end
  end

  def self.get_records(params)
    previous_date_time = params[:previous_date_time].present? ? (params[:previous_date_time]) : "01/01/1990 13:26:58".to_time.utc
    end_event_date = Time.now.utc + 2.minutes
   
    @event = Event.find_by_id(params[:event_id])
    data = {}

    conversation = @event.conversations.paginate(page: params[:page], per_page: 10)
    conversations = conversation.where(:updated_at => previous_date_time..end_event_date, :status => 'approved')
    data[:conversations] = conversations.as_json(:except => [ :image_file_name, 
                                              :image_content_type, 
                                              :image_file_size, 
                                              :json_data], 
                                :methods => [ :image_url,
                                              :company_name,
                                              :like_count,
                                              :user_name,
                                              :comment_count, 
                                              :formatted_created_at_with_event_timezone, 
                                              :formatted_updated_at_with_event_timezone, 
                                              :first_name, 
                                              :last_name, 
                                              :profile_pic_url, 
                                              :share_count]) 

    comments = Comment.where(:commentable_id => conversations.pluck(:id), commentable_type: "Conversation", :updated_at => previous_date_time..end_event_date) 
    data[:comments] = comments.as_json(:only => [ :id, 
                                              :commentable_id, 
                                              :commentable_type, 
                                              :user_id,
                                              :description, 
                                              :created_at, 
                                              :updated_at],
                                   :methods => [ :user_name, 
                                                 :formatted_created_at_with_event_timezone,
                                                 :formatted_updated_at_with_event_timezone,
                                                 :first_name, 
                                                 :last_name]) 
    return data
  end

  def self.get_likes_data(params)  
    data = {}
    conversation = Conversation.find_by_id(params[:id])
    data[:conversation] = conversation.likes.as_json(:methods => [:user_name,
                                                                  :first_name,
                                                                  :last_name]) 
  end
end
