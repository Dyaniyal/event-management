class InviteeGroup < ActiveRecord::Base
	belongs_to :event
  serialize :invitee_ids, Array
  validates :name, :invitee_ids, presence:{ :message => "This field is required." }
  
  def get_invitee_name
    names = ""
    names = Invitee.where("id IN(?)",self.invitee_ids).map {|i| i.name_of_the_invitee} rescue nil if self.invitee_ids.present?
    names.join(",")
  end

  def default_logical_group?
    if ['No Polls taken', 'No Feedback given', 'No Quiz taken', 'No Q&A Participation', 'No Participation in Conversations', 'No Favorites added'].include? self.name
      true
    else
      false
    end
  end

  def get_invitee_ids
    invitee_ids = []
    if ['No Polls taken', 'No Feedback given', 'No Quiz taken', 'No Q&A Participation', 'No Participation in Conversations', 'No Favorites added'].include? self.name
      case self.name
      when 'No Polls taken'
        invitee_ids = Analytic.where(:action => 'poll answered', :viewable_type => 'Poll', :event_id => self.event_id).pluck(:invitee_id).uniq
      when 'No Feedback given'
        invitee_ids = Analytic.where(:action => 'feedback given', :viewable_type => 'Feedback', :event_id => self.event_id).pluck(:invitee_id).uniq
      when 'No Quiz taken'
        invitee_ids = Analytic.where(:action => 'played', :viewable_type => 'Quiz', :event_id => self.event_id).pluck(:invitee_id).uniq
      when 'No Q&A Participation'
        invitee_ids = Analytic.where(:action => 'question asked', :viewable_type => 'Q&A', :event_id => self.event_id).pluck(:invitee_id).uniq
      when 'No Participation in Conversations'
        invitee_ids = Analytic.where(:action => 'conversation post', :viewable_type => 'Conversation', :event_id => self.event_id).pluck(:invitee_id).uniq
      when 'No Favorites added'
        invitee_ids = Analytic.where(viewable_type: "Invitee", action: 'favorite', event_id: self.event_id).pluck(:invitee_id).uniq
      end
      invitee_ids = invitee_ids.present? ? Invitee.where("event_id = ? and id NOT IN (?)", self.event_id, invitee_ids).pluck(:id) : Invitee.where("event_id = ?", self.event_id).pluck(:id)
      invitee_ids = invitee_ids.map{|n| n.to_s}
      self.update_attributes(:invitee_ids => invitee_ids)
      invitee_ids
    else
      invitee_ids = self.invitee_ids
    end
    invitee_ids
  end

end