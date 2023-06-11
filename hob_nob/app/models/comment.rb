class Comment < ActiveRecord::Base
  
  attr_accessor :platform
  belongs_to :commentable, polymorphic: true, :counter_cache => :comments_count_cache
  belongs_to :user, :class_name => 'Invitee', :foreign_key => 'user_id'
  
  validates :description,:commentable_id,:commentable_type,:user_id,:presence =>true
  
  after_create :create_analytic_record
  after_save :update_conversation, :update_last_updated_model, :update_conversation_records_for_create
  after_destroy :update_conversation_records_for_destroy

  default_scope { order('created_at desc') }
  
  def update_conversation_records_for_create
    conversation = Conversation.find_by_id(self.commentable_id)
    invitee = Invitee.find(self.user_id)
    if conversation.present?
      conversation.update_column(:action, 'Comment')
      conversation.update_column(:actioner_id, self.user_id)       
      conversation.update_column(:first_name_user, invitee.first_name)
      conversation.update_column(:last_name_user, invitee.last_name)
      conversation.update_column(:profile_pic_url_user, invitee.profile_pic.url)
      conversation.update_column(:last_update_comment_description, self.description)
      conversation.update_last_updated_model
      conversation.update_column(:updated_at, self.updated_at)
    end
  end

  def update_conversation_records_for_destroy
    conversation = Conversation.find_by_id(self.commentable_id) rescue nil    
    conversation.update_column(:action, nil) if conversation.present?
    conversation.update_column(:updated_at, self.updated_at)
    conversation.update_column(:last_interaction_at, self.updated_at)
  end


  def update_last_updated_model
    LastUpdatedModel.update_record(self.class.name)
  end

  def commented_user_name
    # Invitee.find_by_id(self.user_id).name_of_the_invitee rescue ""
    self.user.name_of_the_invitee rescue ""
  end

  def update_conversation
    c = Conversation.find_by_id(self.commentable_id)
    c.update_columns(updated_at: Time.now.utc, last_interaction_at: Time.now.utc) if c.present?
  end

  def self.get_comments(conversations, start_event_date, end_event_date)
    data = []
    conversations.each do |conversation|
      data << Comment.where(:commentable_id => conversation.id, :commentable_type => "Conversation", :updated_at =>  start_event_date..end_event_date).limit(5)
    end
    data.flatten!
  end

  def commented_user_email
    self.user.email rescue ""
  end

  def email
    # self.user.email rescue ""
    # binding.pry 
    user_id = Conversation.find_by_id(self.commentable_id).user_id
    email = Invitee.find_by_id(user_id).email rescue ""
    return email
  end

  def email_id
    user_id = Conversation.find_by_id(self.commentable_id).user_id
    email = Invitee.find_by_id(user_id).email rescue ""
    return email
  end

  def user_name
    Rails.cache.fetch("comment_invitee_user_name_#{self.user_id}") { user_name! }
  end

  def user_name!
    self.user.name_of_the_invitee rescue nil
  end

  def name
    self.user.name_of_the_invitee rescue ""
  end

  def first_name
    Rails.cache.fetch("comment_invitee_first_name_#{self.user_id}") { first_name! }
  end  

  def first_name!
    # Invitee.find_by_id(self.user_id).first_name rescue ""
    # user_id = Conversation.find_by_id(self.commentable_id).user_id
    # first_name = Invitee.find_by_id(user_id).first_name rescue ""
    # return first_name
    user = self.user
    (user.present? ? user.first_name : "")
  end
  
  def invitee_first_name
    user_id = Conversation.find_by_id(self.commentable_id).user_id
    invitee_first_name = Invitee.find_by_id(user_id).first_name rescue ""
    return invitee_first_name
  end

  def last_name
    Rails.cache.fetch("comment_invitee_last_name_#{self.user_id}") { last_name! }
  end

  def last_name!
    # user_id = Conversation.find_by_id(self.commentable_id).user_id
    # last_name = Invitee.find_by_id(user_id).last_name rescue ""
    # return last_name
    # Invitee.find_by_id(self.user_id).last_name rescue ""
    user = self.user
    (user.present? ? user.last_name : "")
  end
  
  def invitee_last_name
    user_id = Conversation.find_by_id(self.commentable_id).user_id
    invitee_last_name = Invitee.find_by_id(user_id).last_name rescue ""
    return invitee_last_name
  end

  def conversation
    conversation = self.commentable.description
    return conversation.gsub(/[\r\n]/, '')
  end

  def comment
    self.description
  end

  def like_count
    Like.where(:likable_id => self.commentable_id, :likable_type => "Conversation").length rescue 0
  end
  
  def timestamp
    commentable_rec = self.commentable
    commentable_rec.created_at.in_time_zone(commentable_rec.event_timezone).strftime('%m/%d/%Y %H:%M') rescue ""
  end
  def image_url
    conversation = Conversation.find_by_id(self.commentable_id)
    url = conversation.present? ? conversation.image.url(:large) : conversation.image.url
    url = "" if url == "/images/large/missing.png"
    url
  end
  
  def create_analytic_record
    event_id = Invitee.find_by_id(self.user_id).event_id rescue nil
    analytic = Analytic.new(viewable_type: self.commentable_type, viewable_id: self.commentable_id, action: "comment", invitee_id: self.user_id, event_id: event_id, platform: platform)
    self.update_column("analytic_id",analytic.id) if analytic.save
  end

  def self.get_top_commented(count, type, event_id, from_date, to_date)
    conversation_ids = Conversation.where(:event_id => event_id).pluck(:id)
    comments = Comment.where('commentable_type = ? and commentable_id IN (?) and Date(created_at) >= ? and Date(created_at) <= ?', type, conversation_ids, from_date, to_date)
    comments.group(:commentable_id).count.sort_by{|k, v| v}.last(count).reverse
  end

  def post_id
    self.commentable.id
  end

  def Status
    self.commentable.status rescue ""
  end

  def created_at_with_event_timezone
    timezone = Conversation.joins(:event).select("conversations.id as conversation_id, events.id as event_id, events.timezone as timezone").where("conversations.id = ?", self.commentable_id).first.timezone
    self.created_at.in_time_zone(timezone)
  end

  def updated_at_with_event_timezone
    timezone = Conversation.joins(:event).select("conversations.id as conversation_id, events.id as event_id, events.timezone as timezone").where("conversations.id = ?", self.commentable_id).first.timezone
    self.updated_at.in_time_zone(timezone)
  end

  def formatted_created_at_with_event_timezone
    Rails.cache.fetch("formatted_created_at_with_event_timezone_#{self.id}") { formatted_created_at_with_event_timezone! }
  end

  def formatted_created_at_with_event_timezone!
    # self.created_at_with_event_timezone.strftime("%b %d at %I:%M %p (GMT %:z)")
    # created_at_with_tmz = self.created_at_with_event_timezone.strftime("%Y %b %d at %l:%M %p (GMT %:z)")
    conversation = Conversation.find(self.commentable_id)
    created_at_with_tmz = (self.created_at + conversation.event_timezone_offset.to_i.seconds).strftime("%Y %b %d at %l:%M %p (") + conversation.event_display_time_zone.to_s + ")"
    year = Time.now.strftime("%Y") + " "
    created_at_with_tmz.sub(year, "")    
  end

  def formatted_updated_at_with_event_timezone
    Rails.cache.fetch("formatted_updated_at_with_event_timezone_#{self.id}") { formatted_updated_at_with_event_timezone! }
  end

  def formatted_updated_at_with_event_timezone!
    # self.updated_at_with_event_timezone.strftime("%b %d at %I:%M %p (GMT %:z)")
    # updated_at_with_tmz = self.updated_at_with_event_timezone.strftime("%Y %b %d at %l:%M %p (GMT %:z)")
    conversation = Conversation.find(self.commentable_id)
    updated_at_with_tmz = (self.updated_at + conversation.event_timezone_offset.to_i.seconds).strftime("%Y %b %d at %l:%M %p (") + conversation.event_display_time_zone.to_s + ")"    
    year = Time.now.strftime("%Y") + " "
    updated_at_with_tmz.sub(year, "")
  end

end
