class Analytic < ActiveRecord::Base

  VIEWABLE_TYPE_TO_ACTION = {'Conversation' => ['conversation post', 'like', 'comment'], 'Favorite' => ['favorite'], 'Ratings' => ['rated'], 'Rating' => ['rated'], 'Q&A' => ['question asked'], 'Poll' => ['poll answered'], 'Feedback' => ['feedback given'], 'E-Kit' => ['page view'], 'Quiz' => ['played'], 'QR code scan' => ['qr code scan']}

  ACTION_TO_VIEWABLE_TYPE = {"favorite" => 'Favorite', "rated" => 'Rating', "qr code scan" => 'QR Code Scan', "comment" => 'Comment', "conversation post" => 'Conversation', "like" => 'Like', "played" => 'Quiz', "question asked" => 'Q&A', "login" => 'Login', "Login" => 'Login', "poll answered" => 'Poll', "feedback given" => 'Feedback', 'continue' => 'Event Highlight', 'profile_pic' => 'Profile Pic Update', 'Add To Calender' => 'Add To Calender', 'one_on_one' => 'Chat', 'group_chat' => 'Chat', "share" => "Share"}
  ACTION_POINTS = {"favorite" => 5, "rated" => 5, "comment" => 2, "conversation post" => 5, "like" => 2, "quiz correct answer" => 5, "quiz incorrect answer" => 2, "question asked" => 5, "poll answered" => 5, "feedback given" => 10, 'e_kits' => 5, 'Login' => 10, 'profile_pic' => 5, 'page view' => 5, "played" => 5, 'Add To Calender' => 10, 'one_on_one' => 0, 'group chat' => 0, 'share' => 5, 'scan qr code' => 5}
  TOP_PAGE_LIST_TO_FEATURES = {'top_pages' => 'pages', 'top_fav_agendas' => 'agendas', 'top_rated_agendas' => 'agendas', 'top_rated_speakers' => 'speakers', 'top_fav_speakers' => 'speakers', 'top_question_speakers' => 'speakers', 'top_commented_conversations' => 'conversations', 'top_liked_conversations' => 'conversations', 'top_viewed_ekits' => 'e_kits', 'top_answered_quizzes' => 'quizzes', 'top_answered_polls' => 'polls', 'top_fav_invitees' => 'invitees', 'top_fav_sponsors' => 'sponsors', 'top_viewed_sponsors' => 'sponsors', 'top_fav_exhibitors' => 'exhibitors', 'top_viewed_exhibitors' => 'exhibitors', 'top_fav_leaderboard' => 'leaderboard'}
  VIEWABLE_TYPE_TO_FEATURE = {"Invitee" => 'invitees', "Event Highlight" => 'event_highlights', "Gallery listing" => 'galleries', "Speaker" => 'speakers', "Exhibitors" => 'exhibitors', "My Favorite" => 'favourites', "Exhibitors listing" => 'exhibitors', "About" => 'abouts', "Agenda" => 'agendas', "Sessions" => 'agendas', "Conversation" => 'conversations', "Quiz" => 'quizzes', "Poll" => 'polls', "Sponsor" => 'sponsors', "Speakers" => 'speakers', "Q&A" => 'qnas', "My Profile" => 'my_profile', "Sponsors" => 'sponsors', "E-Kit" => 'e_kits', "Event" => 'event_highlights', "Highlights" => 'event_highlights', "Contacts" => 'contacts', "Gallery" => 'galleries', "Feedback" => 'feedbacks', "FAQ" => 'faqs', "Venue" => 'venue', "Notes" => 'notes', "Exhibitor" => 'exhibitors', "Quiz listing" => 'quizzes', "Emergency Exit" => 'emergency_exits', "Edit" => 'my_profile', "Edit Profile" => 'my_profile', "Event Listing" => 'event_highlights', "Contact" => 'contacts', "Note" => 'notes', "Attendee" => 'invitees', 'top_fav_leaderboard' => 'Top Favorited Leader Boards',"Map" => "maps"}

  # validates_uniqueness_of :user_id, :scope => [:quiz_id], :message => 'Quiz already answered'

  scope :desc_ordered, -> { order('created_at DESC') }
  scope :activity_feed_actions, -> { where('action IN (?)', ["comment", "conversation post", "like", "notification"])}
  scope :include_not_rejected, -> { where(status:[nil,"","approved"]) }


  belongs_to :event
  before_create :update_points
  after_create :update_points_to_invitee
  after_save :update_last_updated_model, :update_conversation

   def update_conversation
     if self.viewable_type == "Conversation" and self.action == "share"
       conversation = Conversation.find(self.viewable_id)
       invitee = Invitee.find(self.invitee_id)
       conversation.update_column(:updated_at, self.updated_at)
       conversation.update_column(:action, self.action)
       conversation.update_column(:first_name_user, invitee.first_name)
       conversation.update_column(:last_name_user, invitee.last_name)
       conversation.update_column(:profile_pic_url_user, invitee.profile_pic.url)
       Rails.cache.delete("invitee_share_count_#{conversation.id}")
     end
   end

  def update_last_updated_model
    LastUpdatedModel.update_record(self.class.name)
  end

  def check_ekit_viewed
    if Analytic.where(:action => 'page view', :viewable_type => "E-Kit", :invitee_id => self.invitee_id, :event_id => self.event_id).present?
      self.errors.add :viewable_type, 'already viewed and got points'
    end
    self.errors.present? ? false : true
  end

  def invitee_email
    invitee = Invitee.unscoped.find_by_id(self.invitee_id)
    invitee.present? ? invitee.email : ' '
  end

  def url
    self.viewable_url.present? ? self.viewable_url : ' '
  end

  def timestamp
    event = Event.find(self.event_id)
    (self.created_at + event.timezone_offset.to_i.seconds).strftime('%d/%m/%Y %H:%M')
  end 

  def update_points
    error = []
    error << false if self.action == 'Login' and Analytic.where(:action => 'Login', :viewable_type => "Invitee", :invitee_id => self.invitee_id, :event_id => self.event_id).present?
    error << false if self.action == 'feedback given' and Analytic.where(:action => 'feedback given', :viewable_type => 'Feedback', :invitee_id => self.invitee_id, :event_id => self.event_id).present?
    error << false if self.action == 'page view' and Analytic.where(:action => 'page view', :viewable_type => 'E-Kit', :invitee_id => self.invitee_id, :viewable_id => self.viewable_id, :event_id => self.event_id).present?
    event = self.event
    feature = event.event_features.where(:name => "leaderboard") rescue nil
    if feature.present?
      if error.exclude? false and ((self.points.blank? or (self.points.present? and self.points == 0)) and ["favorite", "rated", "comment", "conversation post", "like", "question asked", "played", "poll answered", "feedback given", 'profile_pic', 'Login', 'Add To Calender', 'share', 'scan qr code'].include? self.action or (self.viewable_type == 'E-Kit' and self.viewable_id.present?))
        self.points = Analytic::ACTION_POINTS[self.action]
      elsif self.points.blank?
        self.points = 0
      end
    else
      self.points = 0
    end  
  end

  def update_points_to_invitee
    event = self.event
    feature = event.event_features.where(:name => "leaderboard") rescue nil
    if feature.present? and feature.first.menu_visibilty.to_s == "active" and self.points > 0
      if self.invitee_id.present? and (["favorite", "rated", "comment", "conversation post", "like", "played", "question asked", "poll answered", "feedback given", 'profile_pic', 'Login', 'Add To Calender', 'share', 'scan qr code'].include? self.action or (self.viewable_type == 'E-Kit' and self.viewable_id.present?) )
        invitee = Invitee.find_by_id(self.invitee_id)
        invitee.update_column(:points, invitee.points.to_i + self.points.to_i) if invitee.present?
        invitee.update_column(:updated_at, Time.now) if invitee.present?
      end
    end  
  end

  def self.get_top_three_ids(event_id, from_date, to_date)
    Analytic.where('viewable_type = ? and event_id = ? and Date(created_at) >= ? and Date(created_at) <= ?', 'Speaker', event_id, from_date, to_date).group(:viewable_id).count.sort_by{|k, v| v}.last(3).map{|a| a[0]}
  end

  def self.get_top_speakers(count, event_id, from_date, to_date)
    Analytic.where('viewable_type = ? and action = ? and event_id = ? and Date(created_at) >= ? and Date(created_at) <= ?', 'Speaker', 'rating', event_id, from_date, to_date).group(:viewable_id).count.sort_by{|k, v| v}.last(count).map{|a| a[0]}.compact
  end

  def self.get_feature_usage(event_id, from_date, to_date)#get_feature_usage(event_id, from_date, to_date)
    # features_arr = EventFeature.where('event_id = ? and name IN (?)', event_id, ['conversations', 'favourites', 'qnas', 'polls', 'feedbacks', 'e_kits', 'quizzes', 'qr_code', 'rating']).pluck(:name)
    # features_arr = features_arr.map{|feature| MobileApplication::USER_ENGAGEMENT_FEATURE[feature]}.compact
    # features_arr = features_arr + ['rating']
    # analytics = Analytic.where('event_id = ? and Date(created_at) >= ? and Date(created_at) <= ?', event_id, from_date, to_date)
    # arr = analytics.group(:viewable_type).count.sort_by{|k, v| v}.reverse
    # [analytics.count, arr]
    analytics = Analytic.where('event_id = ? and action IN (?) and Date(created_at) >= ? and Date(created_at) <= ? or event_id = ? and viewable_type = ? and action IN (?) and Date(created_at) >= ? and Date(created_at) <= ?', event_id, ['qr code scan', 'played', 'feedback given', 'poll answered', 'question asked', 'conversation post', 'like', 'comment', 'rated', 'favorite'], from_date, to_date, event_id, 'E-Kit', ['page view'], from_date, to_date)
    user_engagement = []
    all_features = EventFeature.where('event_id = ?', event_id)
    selected_features = all_features.where('event_id = ? and name IN (?)', event_id, ['conversations', 'favourites', 'qnas', 'polls', 'feedbacks', 'e_kits', 'quizzes', 'qr_code'], ).pluck(:name)
    selected_features = selected_features + ['ratings'] if all_features.pluck(:name).include? 'agendas' or all_features.pluck(:name).include? 'speakers'
    selected_features = selected_features + ['one_on_one'] if all_features.pluck(:name).include? 'chats'
    selected_features.each do |feature|
      user_engagement  << Analytic.get_feature_engagement_count(event_id, feature, from_date, to_date)
    end
    [user_engagement.map{|a| a[1]}.sum, user_engagement]
  end


  def self.get_feature_engagement_count(event_id, feature, from_date, to_date)
    case feature
      when 'conversations'
        ['Conversations', Analytic.where('event_id = ? and action IN (?) and Date(created_at) >= ? and Date(created_at) <= ?', event_id, ['conversation post', 'like', 'comment'], from_date, to_date).count]
      when 'favourites'
        ['Favorites', Analytic.where('event_id = ? and action IN (?) and Date(created_at) >= ? and Date(created_at) <= ?', event_id, ['favorite'], from_date, to_date).count]
      when 'ratings'
        ['Ratings', Analytic.where('event_id = ? and action IN (?) and Date(created_at) >= ? and Date(created_at) <= ?', event_id, ['rated'], from_date, to_date).count]
      when 'qnas'
        ['Questions Asked', Analytic.where('event_id = ? and action IN (?) and Date(created_at) >= ? and Date(created_at) <= ?', event_id, ['question asked'], from_date, to_date).count]
      when 'polls'
        ['Polls taken', Analytic.where('event_id = ? and action IN (?) and Date(created_at) >= ? and Date(created_at) <= ?', event_id, ['poll answered'], from_date, to_date).count]
      when 'feedbacks'
        ['Feedback Submitted', Analytic.where('event_id = ? and action IN (?) and Date(created_at) >= ? and Date(created_at) <= ?', event_id, ['feedback given'], from_date, to_date).count]
      when 'e_kits'
        ['e-Kit Document Views', Analytic.where('viewable_type = ? and event_id = ? and action IN (?) and Date(created_at) >= ? and Date(created_at) <= ? and viewable_id IS NOT NULL', 'E-Kit', event_id, ['page view'], from_date, to_date).count]
      when 'quizzes'
        ['Quiz answered', Analytic.where('event_id = ? and action IN (?) and Date(created_at) >= ? and Date(created_at) <= ?', event_id, ['played'], from_date, to_date).count]
      when 'qr_code'
        ['QR Code scans', Analytic.where('event_id = ? and action IN (?) and Date(created_at) >= ? and Date(created_at) <= ?', event_id, ['qr code scan'], from_date, to_date).count]
      when 'one_on_one'
        ['one on one chat', Analytic.where('event_id = ? and action IN (?) and Date(created_at) >= ? and Date(created_at) <= ?', event_id, ['one_on_one'], from_date, to_date).count]
    end
  end

  def self.get_top_three_pages(event_id, from_date, to_date)
    analytics = Analytic.where('action = ? and event_id = ? and Date(created_at) >= ? and Date(created_at) <= ?', 'page view', event_id, from_date, to_date)
    arr = analytics.group(:viewable_type).count.sort_by{|k, v| v}.last(3).reverse
    [analytics.count, arr]
  end

  def self.get_top_three_actions(event_id, from_date, to_date)
    #analytics = Analytic.where('action != ? and event_id = ? and Date(created_at) >= ? and Date(created_at) <= ?', 'page view', event_id, from_date, to_date)
    analytics = Analytic.where('action NOT IN (?) and event_id = ? and Date(created_at) >= ? and Date(created_at) <= ?', ['page view', 'notification'], event_id, from_date, to_date)
    arr = analytics.group(:action).count.sort_by{|k, v| v}.last(3).reverse
    [analytics.count, arr]
  end

  def self.get_top_pages(count, event_id, from_date, to_date)
    analytics = Analytic.where('action = ? and event_id = ? and Date(created_at) >= ? and Date(created_at) <= ? and viewable_type NOT IN (?)', 'page view', event_id, from_date, to_date, ['Attendee'])
    arr = analytics.group(:viewable_type).count.sort_by{|k, v| v}.last(count).reverse
    [analytics.count, arr]
  end

  def self.get_top_actions(count, event_id, from_date, to_date)
    #analytics = Analytic.where('action != ? and event_id = ? and Date(created_at) >= ? and Date(created_at) <= ?', 'page view', event_id, from_date, to_date)
    analytics = Analytic.where('action NOT IN (?) and event_id = ? and Date(created_at) >= ? and Date(created_at) <= ?', ['page view', 'notification'], event_id, from_date, to_date)
    arr = analytics.group(:action).count.sort_by{|k, v| v}.last(count).reverse
    [analytics.count, arr]
  end

  def self.get_uniq_user_usage(event_id, from_date, to_date)
    analytics = Analytic.where('platform IS IN (?) and event_id = ? and Date(created_at) >= ? and Date(created_at) <= ?', ['Android', 'Ios'], event_id, from_date, to_date)
    android_analytics = analytics.where(:platform => 'Android').pluck(:invitee_id).uniq.count
    ios_analytics = analytics.where(:platform => 'Ios').pluck(:invitee_id).uniq.count
    arr = [['Android', ((android_analytics / analytics.pluck(:invitee_id).uniq.count.to_f) * 100).to_i], ['Ios', ((ios_analytics / analytics.pluck(:invitee_id).uniq.count.to_f) * 100).to_i]]
  end

  def self.get_unique_users(event_id, from_date, to_date)
    all_analytics = Analytic.where('viewable_type = ? and action = ? and event_id = ?', 'Invitee', 'Login', event_id)
    analytics = all_analytics.where('Date(created_at) >= ? and Date(created_at) <= ?', from_date, to_date)
    invitee_ids = analytics.pluck(:invitee_id).uniq
    unique_users_count = Invitee.where(:id => invitee_ids).count
    ios_analytics = analytics.where(:platform => 'Ios').pluck(:invitee_id).uniq.count
    android_analytics = analytics.where(:platform => 'Android').pluck(:invitee_id).uniq.count
    arr = [[['Android', android_analytics], ['Ios', ios_analytics]], [unique_users_count, all_analytics.pluck(:invitee_id).uniq.count]]
  end

  def self.get_total_detail_users(event_id, from_date, to_date)
    all_analytics = Analytic.where('viewable_type = ? and action = ? and event_id = ?', 'Invitee', 'Login', event_id)
    analytics = all_analytics.where('Date(created_at) >= ? and Date(created_at) <= ?', from_date, to_date)
    invitee_ids = analytics.pluck(:invitee_id).uniq
    unique_users_count = Invitee.where(:id => invitee_ids).count
    active_users_count = Invitee.where('id IN (?) and last_interation >= ?', invitee_ids, (Time.now - 24.hours)).count
    arr = [unique_users_count, active_users_count]
  end

  def self.get_active_users(event_id, from_date, to_date)
    all_analytics = Analytic.where('viewable_type = ? and action = ? and event_id = ?', 'Invitee', 'Login', event_id)
    analytics = all_analytics.where('Date(created_at) >= ? and Date(created_at) <= ?', from_date, to_date)
    viewable_ids = analytics.pluck(:invitee_id).uniq
    active_user_ids = Invitee.where('id IN (?) and last_interation >= ?', viewable_ids, (Time.now - 24.hours)).pluck(:id)
    analytics = analytics.where(:invitee_id => active_user_ids)
    ios_analytics = analytics.where(:platform => 'Ios').pluck(:viewable_id).count
    android_analytics = analytics.where(:platform => 'Android').pluck(:viewable_id).count
    arr = [[['Android', android_analytics], ['Ios', ios_analytics]], [active_user_ids.count, all_analytics.pluck(:invitee_id).uniq.count]]
  end

  def self.get_user_engagements(event_id, from_date, to_date, filter_date)
    overall, data = [], []
    analytics = Analytic.where("event_id = ? and Date(created_at) >= ? and Date(created_at) <= ?" , event_id, from_date, to_date)
    if analytics.present?
      user_engagement = []
      features = {"conversations" => "Conversation", "favourites" => "Favorite", "qnas" => "Q&A", "polls" => "Poll", "feedbacks" => "Feedback", "e_kits" => "E-Kit", "qr_code" => "QR code scan", "quizzes" => "Quiz"}
      event = Event.find_by_id(event_id)
      if event.present?
        event.event_features.each do |f|
          user_engagement  << features[f.name] if features.keys.include? f.name
        end
      end
      user_engagement << 'Rating' if event.event_features.map{|f| f.name}.include? 'speakers' or event.event_features.map{|f| f.name}.include? 'agendas'
      user_engagement += ['One on one chat'] if event.event_features.map{|f| f.name}.include? 'chats'
      user_engagement.each do |engagement|
        (from_date.to_date..to_date.to_date).each do |dt|
          if engagement == 'Favorite'
            type = ['Invitee', 'Sponsor', 'Agenda', 'Agendas', 'Sessions', 'Speaker', 'Speakers', 'Exhibitor', 'Exhibitors']
            count = Favorite.where('favoritable_type IN (?) and event_id = ? and Date(created_at) = ?', type, event_id, dt).count
            # count = analytics.where('Date(created_at) = ? and viewable_type IN (?) and action IN (?)', dt, type, Analytic::VIEWABLE_TYPE_TO_ACTION[engagement]).count
          elsif engagement == 'Rating'
            type = ['Agenda', 'Speaker']
            count = analytics.where('Date(created_at) = ? and viewable_type IN (?) and action IN (?)', dt, type, Analytic::VIEWABLE_TYPE_TO_ACTION[engagement]).count
          elsif engagement == 'QR code scan'
            type = ['Invitee']
            count = analytics.where('Date(created_at) = ? and viewable_type IN (?) and action IN (?)', dt, type, Analytic::VIEWABLE_TYPE_TO_ACTION[engagement]).count
          elsif engagement == 'E-Kit'
            type = ['E-Kit']
            count = analytics.where('Date(created_at) = ? and viewable_type IN (?) and action IN (?) and viewable_id IS NOT NULL', dt, type, Analytic::VIEWABLE_TYPE_TO_ACTION[engagement]).count
          elsif engagement == 'One on one chat'
            type = ['Chat']
            query_engagement = ['One on one chat', 'one_on_one']
            count = analytics.where('Date(created_at) = ? and viewable_type IN (?) and action IN (?)', dt, type, query_engagement).count
          else
            count = analytics.where('Date(created_at) = ? and viewable_type = ? and action IN (?)', dt, engagement, Analytic::VIEWABLE_TYPE_TO_ACTION[engagement]).count
          end
          data << count;
        end
        if data.sum == 0
          length = data.length
          data = [nil]*length
        else
          data
        end
        overall << {name: engagement, data: data}
        data = []
      end
    end
    overall
  end


  def self.get_today_user_engagements(event_id, from_date, to_date)
    event = Event.find(event_id)
    today_date = Date.today
    overall, data, hsh = [], [], {}
    analytics = Analytic.where("event_id = ? and Date(created_at) >= ? and Date(created_at) <= ?", event_id, from_date, from_date)
    if analytics.present?
      user_engagement = []
      features = {"conversations" => "Conversation", "favourites" => "Favorite", "qnas" => "Q&A", "polls" => "Poll", "feedbacks" => "Feedback", "e_kits" => "E-Kit", "qr_code" => "QR code scan", "quizzes" => "Quiz"}
      event = Event.find_by_id(event_id)
      if event.present?
        event.event_features.each do |f|
          user_engagement  << features[f.name] if features.keys.include? f.name
        end
      end
      user_engagement << "Rating" if event.event_features.map{|f| f.name}.include? 'speakers' or event.event_features.map{|f| f.name}.include? 'agendas'
      user_engagement += ['One on one chat'] if event.event_features.map{|f| f.name}.include? 'chats'
      user_engagement.each do |engagement|
        (0..23).each do |hour|
          q_time = today_date.strftime('%Y/%m/%d ') + hour.to_s + ":00"
          q_time = q_time.to_datetime.in_time_zone(event.timezone).beginning_of_hour
          # q_time = (q_time.to_datetime + event.timezone_offset.to_i.seconds).beginning_of_hour
          if engagement == 'Favorite'
            type = ['Invitee', 'Sponsor', 'Agenda', 'Agendas', 'Sessions', 'Speaker', 'Speakers', 'Exhibitor', 'Exhibitors']
            count = Favorite.where('favoritable_type IN (?) and event_id = ? and created_at >= ? and created_at <= ?', type, event_id, q_time.to_datetime, (q_time.to_datetime + 1.hour)).count
          elsif engagement == 'Rating'
            type = ['Agenda', 'Speaker']
            count = analytics.where('created_at >= ? and created_at <= ? and viewable_type IN (?) and action IN (?)', q_time.to_datetime, (q_time.to_datetime + 1.hour), type, Analytic::VIEWABLE_TYPE_TO_ACTION[engagement]).count
          elsif engagement == 'QR code scan'
            type = ['Invitee']
            count = analytics.where('created_at >= ? and created_at <= ? and viewable_type IN (?) and action IN (?)', q_time.to_datetime, (q_time.to_datetime + 1.hour), type, Analytic::VIEWABLE_TYPE_TO_ACTION[engagement]).count
          elsif engagement == 'E-Kit'
            type = ['E-Kit']
            count = analytics.where('created_at >= ? and created_at <= ? and viewable_type = ? and action IN (?) and viewable_id IS NOT NULL', q_time.to_datetime, (q_time.to_datetime + 1.hour), engagement, Analytic::VIEWABLE_TYPE_TO_ACTION[engagement]).count
          elsif engagement == 'One on one chat'
            type = ['Chat']
            query_engagement = ['One on one chat', 'one_on_one']
            count = analytics.where('created_at >= ? and created_at <= ? and viewable_type IN (?) and action IN (?)', q_time.to_datetime, (q_time.to_datetime + 1.hour), type, query_engagement).count
          else
            count = analytics.where('created_at >= ? and created_at <= ? and viewable_type = ? and action IN (?)', q_time.to_datetime, (q_time.to_datetime + 1.hour), engagement, Analytic::VIEWABLE_TYPE_TO_ACTION[engagement]).count
          end
          hsh[q_time.strftime("%k").to_i] = count
        end
        (0..23).each do |hour|
          hsh[hour] = 0 if hsh[hour].blank?
        end
        hsh = Hash[hsh.sort]
        data = hsh.values
        if data.sum == 0
          length = data.length
          data = [nil]*length
        else
          data
        end
        overall << {name: engagement, data: data}
        data = []
      end
    end
    overall
  end


  def self.get_features_count(event_id, from_date, to_date)
    event_features = EventFeature.where(:event_id => event_id).pluck(:name)
    hsh = {}
    hsh['page_count'] = Analytic.where(:action => 'page view', :event_id => event_id).where('Date(created_at) >= ? and Date(created_at) <= ?', from_date, to_date).count
    hsh['conversations_count'] = Analytic.where(:action => ['conversation post', 'like', 'comment'], :event_id => event_id).where('Date(created_at) >= ? and Date(created_at) <= ?', from_date, to_date).count if event_features.include? 'conversations'
    hsh['qnas_count'] = Analytic.where('action = ? and event_id = ? and Date(created_at) >= ? and Date(created_at) <= ?', 'question asked', event_id, from_date, to_date).count if event_features.include? 'qnas'
    hsh['notifications_count'] = Notification.where('event_id = ? and Date(created_at) >= ? and Date(created_at) <= ?', event_id, from_date, to_date).count
    hsh
  end

  def self.get_x_axis_labels_and_interval(params)
    hsh = {'Today' => (Date.today..Date.today), 'last 7 days' => (Date.today - 7.days)..Date.today}
    if params[:filter_date].present? and params[:filter_date] == 'last 7 days'
      from_date = params[:start_date].blank? ? Date.today.beginning_of_month : params[:start_date].to_date
      to_date = params[:end_date].blank? ? Date.today.end_of_month : params[:end_date].to_date
      x_axis_interval_labels = (from_date..to_date).map{|dt| dt.strftime('%d %b')}
    elsif params[:filter_date].present? and params[:filter_date] == 'date range'
      from_date = params[:start_date].blank? ? Date.today : params[:start_date].to_date
      to_date = params[:end_date].blank? ? Date.today : params[:end_date].to_date
      x_axis_interval_labels = (from_date..to_date).map{|dt| dt.strftime('%d %b')}
    else
      x_axis_interval_labels = ['00:00', '01:00', '02:00', '03:00', '04:00', '05:00', '06:00', '07:00', '08:00', '09:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00', '16:00', '17:00', '18:00', '19:00', '20:00', '21:00', '22:00', '23:00', '24:00']
      x_axis_time_splot = 4
    end
    x_axis_time_splot = (params[:start_date].present? and params[:end_date].present? and (params[:end_date].to_date - params[:start_date].to_date).to_i > 5) ? ((params[:end_date].to_date - params[:start_date].to_date).to_i / 5.0).ceil : 1 if params[:filter_date].present?
    
    [x_axis_interval_labels, x_axis_time_splot]
  end
 
  def self.get_detailed_analytics(params)
    hsh = {}
    all_hsh = {}
    event_id = params[:id]
    event_id = params[:event_id] if params[:event_id].present?
    start_date = params[:start_date].blank? ? (Date.today - 2.week) : params[:start_date].to_date
    end_date = params[:end_date].blank? ? Date.today : params[:end_date].to_date
    features = EventFeature.where(:event_id => event_id).pluck(:name)
    users_arr = self.get_total_detail_users(event_id, start_date, end_date)
    
    hsh['Total unique users'] = users_arr[0] if features.include? 'invitees'
    hsh['Total active users'] = users_arr[1] if features.include? 'invitees'
    hsh['Page views'] = Analytic.where('event_id = ? and action = ? and Date(created_at) >= ? and Date(created_at) <= ?', event_id, 'page view', start_date, end_date).count
    hsh['Conversations'] = Analytic.where('event_id = ? and viewable_type = ? and action IN (?) and Date(created_at) >= ? and Date(created_at) <= ?', event_id, 'Conversation', ['conversation post', 'like', 'comment'], start_date, end_date).count if features.include? 'conversations'
    fav_type = ['Invitee', 'Sponsor', 'Agenda', 'Agendas', 'Sessions', 'Speaker', 'Speakers', 'Exhibitor', 'Exhibitors']
    hsh['Favorites'] = Favorite.where('favoritable_type IN (?) and event_id = ? and Date(created_at) >= ? and Date(created_at) <= ?', fav_type, event_id, start_date, end_date).count if features.include? 'favourites'
    hsh['Speaker Ratings'] = Analytic.where('event_id = ? and action = ? and viewable_type = ? and Date(created_at) >= ? and Date(created_at) <= ?', event_id, 'rated', 'Speaker', start_date, end_date).count if features.include? 'speakers'
    hsh['Session Ratings'] = Analytic.where('event_id = ? and action = ? and viewable_type = ? and Date(created_at) >= ? and Date(created_at) <= ?', event_id, 'rated', 'Agenda', start_date, end_date).count if features.include? 'agendas'
    hsh['Questions Asked'] = Analytic.where('event_id = ? and action = ? and Date(created_at) >= ? and Date(created_at) <= ?', event_id, 'question asked', start_date, end_date).count if features.include? 'qnas'
    hsh['Polls taken'] = Analytic.where('event_id = ? and action = ? and Date(created_at) >= ? and Date(created_at) <= ?', event_id, 'poll answered', start_date, end_date).count if features.include? 'polls'
    hsh['Feedback Submitted'] = Analytic.where('event_id = ? and action = ? and Date(created_at) >= ? and Date(created_at) <= ?', event_id, 'feedback given', start_date, end_date).count if features.include? 'feedbacks'
    hsh['e-Kit Document Views'] = Analytic.where('event_id = ? and viewable_type = ? and action = ? and Date(created_at) >= ? and Date(created_at) <= ? and viewable_id IS NOT NULL', event_id, 'E-Kit', 'page view', start_date, end_date).count if features.include? 'e_kits'
    hsh['Quiz answered'] = Analytic.where('event_id = ? and action = ? and Date(created_at) >= ? and Date(created_at) <= ?', event_id, 'played', start_date, end_date).count if features.include? 'quizzes'
    hsh['QR Code scans'] = Analytic.where('event_id = ? and action = ? and Date(created_at) >= ? and Date(created_at) <= ?', event_id, 'qr code scan', start_date, end_date).count if features.include? 'qr_code'
    #hsh['Notifications sent'] = Notification.where('event_id = ? and pushed = ? and Date(created_at) >= ? and Date(created_at) <= ?', event_id, true, start_date, end_date).count #if features.include? 'agendas'
    hsh['Notifications sent'] = Notification.where('event_id = ? and Date(created_at) >= ? and Date(created_at) <= ?', event_id, start_date, end_date).count #if features.include? 'agendas'
    all_hsh['user_engagements'] = Analytic.get_user_engagements(event_id, params[:start_date], params[:end_date], params[:filter_date])
    all_hsh['feature_count'] = Analytic.get_features_count(event_id, params[:start_date], params[:end_date])
    all_hsh['xaxis_interval_labels_and_interval'] = Analytic.get_x_axis_labels_and_interval(params)
    all_hsh['top_fav_speakers'] = Favorite.get_top_favorite(10, ['Speakers', 'Speaker'], event_id, start_date, end_date) if features.include? 'speakers' and features.include? 'favourites'
    all_hsh['top_rated_speakers'] = Rating.get_top_rated(10, event_id, 'Speaker', start_date, end_date) if features.include? 'speakers'
    all_hsh['top_question_speakers'] = Qna.get_top_question_speakers(10, event_id, 'Speaker', start_date, end_date) if features.include? 'speakers' and features.include? 'qnas'
    all_hsh['top_pages'] = Analytic.get_top_pages(10, event_id, start_date, end_date)
    all_hsh['top_actions'] = Analytic.get_top_actions(10, event_id, start_date, end_date)
    all_hsh['top_fav_agendas'] = Favorite.get_top_favorite(10, ['Sessions', 'Session'], event_id, start_date, end_date) if features.include? 'agendas' and features.include? 'favourites'
    all_hsh['top_rated_agendas'] = Rating.get_top_rated(10, event_id, 'Agenda', start_date, end_date) if features.include? 'agendas'
    all_hsh['top_viewed_ekits'] = Analytic.get_top_page_views(10, event_id, 'E-Kit', start_date, end_date) if features.include? 'e_kits'
    all_hsh['top_liked_conversations'] = Like.get_top_liked(10, 'Conversation', event_id, start_date, end_date) if features.include? 'conversations'
    all_hsh['top_commented_conversations'] = Comment.get_top_commented(10, 'Conversation', event_id, start_date, end_date) if features.include? 'conversations'
    all_hsh['top_answered_polls'] = UserPoll.get_most_answered(10, event_id, start_date, end_date) if features.include? 'polls'
    all_hsh['top_fav_invitees'] = Favorite.get_top_favorite(10, ['Invitee'], event_id, start_date, end_date) if features.include? 'invitees' and features.include? 'favourites'
    all_hsh['top_fav_sponsors'] = Favorite.get_top_favorite(10, ['Sponsor'], event_id, start_date, end_date) if features.include? 'sponsors' and features.include? 'favourites'
    all_hsh['top_viewed_sponsors'] = Analytic.get_top_page_views(10, event_id, 'Sponsor', start_date, end_date) if features.include? 'sponsors'
    all_hsh['top_fav_exhibitors'] = Favorite.get_top_favorite(10, ['Exhibitor', 'Exhibitors'], event_id, start_date, end_date) if features.include? 'exhibitors' and features.include? 'favourites'
    all_hsh['top_viewed_exhibitors'] = Analytic.get_top_page_views(10, event_id, 'Exhibitor', start_date, end_date) if features.include? 'exhibitors'
    all_hsh['top_answered_quizzes'] = UserQuiz.get_most_answered(10, event_id, start_date, end_date) if features.include? 'quizzes'
    all_hsh['top_fav_leaderboard'] = Invitee.unscoped.where("event_id =? and visible_status =? and points !=?", event_id, 'active', 0).order('points desc').first(10).map{|i| [i.id,i.points]} rescue [] if features.include? 'leaderboard' and features.include? 'invitees'
    [hsh, all_hsh]
  end

  def self.get_top_page_views(count, event_id, type, from_date, to_date)
    Analytic.where('event_id = ? and action = ? and viewable_type = ? and viewable_id IS NOT NULL and Date(created_at) >= ? and Date(created_at) <= ?', event_id, 'page view', type, from_date, to_date).group(:viewable_id).count.sort_by{|k, v| v}.last(count).reverse
  end

  def self.get_top_speakers(count, event_id, from_date, to_date)
    Analytic.where('viewable_type = ? and action = ? and event_id = ? and Date(created_at) >= ? and Date(created_at) <= ?', 'Speaker', 'rating', event_id, from_date, to_date).group(:viewable_id).count.sort_by{|k, v| v}.last(count).map{|a| a[0]}.compact
  end

  def self.get_object(type, id)
    type.singularize.constantize.find_by_id(id)
  end

  def self.get_leaderboards(event_id)
    invitees = Invitee.unscoped.where("event_id =? and visible_status =? and points !=?", event_id, 'active', 0).order('points desc').first(3)
    invitees.map{|i| [i.id,i.points]}
  end

  def self.get_live_analytics(params)
    result_hsh = {}
    hsh = {'Today' => (Date.today..Date.today), 'last 7 days' => (Date.today - 7.days)..Date.today}
    params[:start_date] = (params[:filter_date].present? and params[:filter_date] != 'date range') ? hsh[params[:filter_date]].first.strftime("%Y/%m/%d").to_date : (params[:start_date].present? ? params[:start_date].to_date : Date.today)
    params[:end_date] = (params[:filter_date].present? and params[:filter_date] != 'date range') ? hsh[params[:filter_date]].last.strftime("%Y/%m/%d").to_date : (params[:end_date].present? ? params[:end_date].to_date : Date.today)
    result_hsh['speaker_ids'] = Rating.get_top_three_speaker_ids(params[:id], params[:start_date], params[:end_date])
    result_hsh['pages'] = Analytic.get_top_three_pages(params[:id], params[:start_date], params[:end_date])
    result_hsh['actions'] = Analytic.get_top_three_actions(params[:id], params[:start_date], params[:end_date])
    result_hsh['event_features'] = Analytic.get_feature_usage(params[:id], params[:start_date], params[:end_date])
    result_hsh['active_users'] = Analytic.get_active_users(params[:id], params[:start_date], params[:end_date])
    result_hsh['unique_users'] = Analytic.get_unique_users(params[:id], params[:start_date], params[:end_date])
    result_hsh['leaderboards'] = Analytic.get_leaderboards(params[:id])
    if params[:filter_date].present? and params[:filter_date] != 'Today'
      result_hsh['user_engagements'] = Analytic.get_user_engagements(params[:id], params[:start_date], params[:end_date], params[:filter_date])
    else
      result_hsh['user_engagements'] = Analytic.get_today_user_engagements(params[:id], params[:start_date], params[:end_date])
    end
    result_hsh['feature_count'] = Analytic.get_features_count(params[:id], params[:start_date], params[:end_date])
    result_hsh['xaxis_interval_labels_and_interval'] = Analytic.get_x_axis_labels_and_interval(params)
    result_hsh
  end

  def get_likes(id)
    Analytic.where(:viewable_id => id, :viewable_type => "Conversation",:action => "like")
  end
  
  def get_comments(id)
    Comment.where(:commentable_id => id, :commentable_type => "Conversation",:analytic_id => self.id)
  end

  def get_shares(id)
    Analytic.where(:viewable_id => id, :viewable_type => "Conversation",:action => "share")
  end

end
