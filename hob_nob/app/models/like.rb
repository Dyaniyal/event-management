class Like < ActiveRecord::Base
	
  attr_accessor :platform
  belongs_to :likable, polymorphic: true, :counter_cache => :likes_count_cache
  belongs_to :user, :class_name => 'Invitee', :foreign_key => 'user_id'
  
  validates :user_id, :likable_type, :likable_id, presence: true
  validates_uniqueness_of :user_id, :scope => [:likable_type, :likable_id]
  
  after_create :create_analytic_record
  after_save :update_conversation, :update_conversation_records_for_create
  after_destroy :update_conversation, :update_conversation_records_for_destroy

  def update_conversation
		# Conversation.find_by_id(self.likable_id).update_columns(updated_at: Time.now.utc, last_interaction_at: Time.now.utc)
    conversation = Conversation.find_by_id(self.likable_id)
    if conversation.present?
      conversation.update_columns(updated_at: Time.now.utc, last_interaction_at: Time.now.utc)
    end
	end

  def update_conversation_records_for_create
    conversation = Conversation.find_by_id(self.likable_id) rescue nil
    invitee = Invitee.find(self.user_id)
    if conversation.present?
      conversation.update_column(:action, 'Like')
      conversation.update_column(:actioner_id, self.user_id)       
      conversation.update_column(:first_name_user, invitee.first_name)
      conversation.update_column(:last_name_user, invitee.last_name)      
      conversation.update_column(:profile_pic_url_user, invitee.profile_pic.url(:large))      
      conversation.update_column(:updated_at, self.updated_at)
      conversation.update_last_updated_model
    end
  end

  def update_conversation_records_for_destroy
    conversation = Conversation.find_by_id(self.likable_id) rescue nil    
    conversation.update_column(:action, nil) if conversation.present?
    conversation.update_column(:updated_at, self.updated_at)
  end
	
  def email
    self.user.email
  end

  def user_name
    self.user.name_of_the_invitee rescue ""
  end

  def first_name
    self.user.first_name rescue ""
  end
  
  def last_name
    self.user.last_name rescue ""
  end  

  def conversation
    self.likable.description
  end

  def create_analytic_record
    event_id = Invitee.find_by_id(self.user_id).event_id rescue nil
    analytic = Analytic.new(viewable_type: self.likable_type, viewable_id: self.likable_id, action: "like", invitee_id: self.user_id, event_id: event_id, platform: platform)
    analytic.save rescue nil
  end

  def self.get_top_liked(count, type, event_id, from_date, to_date)
    conversation_ids = Conversation.where(:event_id => event_id).pluck(:id)
    likes = Like.where('likable_type = ? and likable_id IN (?) and Date(created_at) >= ? and Date(created_at) <= ?', type, conversation_ids, from_date, to_date)
    likes.group(:likable_id).count.sort_by{|k, v| v}.last(count).reverse
  end

end
