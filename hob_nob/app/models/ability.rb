class Ability
  include CanCan::Ability

  def initialize(user)

    user ||= User.new
    if user.has_role? :super_admin
      can :manage, :all
    elsif user.has_role? :licensee_admin
      can :create, User
      can :manage, User, :licensee_id => user.id
      can :create, Client#.with_role(:module_admin, user)
      can :create, IconLibrary
      can :manage, IconLibrary, :licensee_id => user.id
      c_ids = Client.with_role(:licensee_admin, user).pluck(:id)
      can :manage, Client, :id => c_ids
      can :create, MobileApplication
      can :manage, MobileApplication
      # can :create, InviteeStructure   
      # can :manage, InviteeStructure
      can :read, InviteeStructure
      can :create, StoreInfo
      can :manage, StoreInfo
      can :create, StoreScreenshot
      can :manage, StoreScreenshot#, :client_id => c_ids
      can :create, EventGroup
      can :manage, EventGroup#, :client_id => c_ids
      c_ids += Event.with_role(:licensee_admin, user).pluck(:client_id)
      c_ids = c_ids.uniq
      can :create, Event
      can :manage, Event#, :client_id => c_ids
      e_ids = Event.where(:client_id => c_ids).pluck(:id).uniq
      can :create, Agenda
      can :manage, Agenda, :event_id => e_ids
      
      can :create, Chat
      can :manage, Chat, :event_id => e_ids
      can :create, InviteeGroup
      can :manage, InviteeGroup, :event_id => e_ids
      can :create, Attendee
      can :manage, Attendee, :event_id => e_ids
      can :create, Invitee
      can :manage, Invitee, :event_id => e_ids
      can :create, Speaker
      can :manage, Speaker, :event_id => e_ids
      can :create, Poll
      can :manage, Poll, :event_id => e_ids
      can :create, Quiz
      can :manage, Quiz, :event_id => e_ids
      can :create, Panel
      can :manage, Panel, :event_id => e_ids
      can :create, Conversation
      can :manage, Conversation, :event_id => e_ids
      can :create, Sponsor
      can :manage, Sponsor, :event_id => e_ids
      can :create, Exhibitor
      can :manage, Exhibitor, :event_id => e_ids
      can :create, Qna
      can :manage, Qna, :event_id => e_ids
      can :create, Award
      can :manage, Award, :event_id => e_ids
      can :create, EventFeature
      can :manage, EventFeature, :event_id => e_ids
      can :create, Faq
      can :manage, Faq, :event_id => e_ids
      can :create, Image
      can :manage, Image, :event_id => e_ids
      can :create, EKit
      can :manage, EKit, :event_id => e_ids
      can :create, Import
      can :manage, Import, :event_id => e_ids
      can :create, Contact
      can :manage, Contact, :event_id => e_ids
      # can :create, Grouping
      # can :manage, Grouping, :event_id => e_ids

      can :create, Notification
      can :manage, Notification, :event_id => e_ids
      can :create, InviteeNotification
      can :manage, InviteeNotification, :event_id => e_ids


      can :create, Registration
      can :manage, Registration

      can :create, RegistrationSetting
      can :manage, RegistrationSetting, :event_id => e_ids

      can :create, CustomPage1
      can :manage, CustomPage1, :event_id => e_ids
      can :create, CustomPage2
      can :manage, CustomPage2, :event_id => e_ids
      can :create, CustomPage3
      can :manage, CustomPage3, :event_id => e_ids
      can :create, CustomPage4
      can :manage, CustomPage4, :event_id => e_ids
      can :create, CustomPage5
      can :manage, CustomPage5, :event_id => e_ids

      can :create, MyTravel
      can :manage, MyTravel, :event_id => e_ids
      can :create, TrackLink
      can :manage, TrackLink, :event_id => e_ids
      can :create, Campaign
      can :manage, Campaign, :event_id => e_ids
      campaign_ids = Campaign.where(:event_id => e_ids).pluck(:id).uniq
      can :create, Edm
      can :manage, Edm, :campaign_id => campaign_ids

      can :create, QnaSetting
      can :manage, QnaSetting, :event_id => e_ids
      q_ids = Qna.where(:event_id => e_ids)
      #can :manage, UserQna, :qna_id => q_ids
      can :create, RegistrationLookAndFeel
      can :manage, RegistrationLookAndFeel, :event_id => e_ids      
	  can :create, TelecallerAccessibleColumn
      can :manage, TelecallerAccessibleColumn, :event_id => e_ids
      s_ids = Speaker.where(:event_id => e_ids).pluck(:id).uniq
      can :manage, Rating, :ratable_id => s_ids, :ratable_type => 'Speaker'
      can :manage, Feedback#, :speaker_id => s_ids

      c_ids = Conversation.where(:event_id => e_ids)
      can :manage, Like, :likable_id => c_ids, :likable_type => 'Conversation'
      can :manage, Comment, :commentable_id => c_ids, :commentable_type => 'Conversation'
      
      p_ids = Poll.where(:event_id => e_ids)
      can :manage, UserPoll, :poll_id => p_ids

      
      a_ids = Award.where(:event_id => e_ids).pluck(:id).uniq
      can :manage, Winner#, :award_id => a_ids  
      
      can :create, Theme
      can :edit, Theme#, :licensee_id => nil
      can :manage, Theme#, :licensee_id => user.get_licensee
      
      can :create, User
      can :manage, User#, :licensee_id => user.get_licensee

      can :create, Map
      can :manage, Map

      can :read, :all

    elsif user.has_role? :client_admin
      can :create, User
      can :manage, User, :licensee_id => user.get_licensee
      
      c_ids = Client.with_role([:client_admin, :licensee_admin], user).pluck(:id)
      c_ids += Event.with_role([:client_admin, :event_admin, :licensee_admin], user).pluck(:client_id)
      can :manage, Client, :id => c_ids
      c_ids = c_ids.uniq
      can :create, MobileApplication
      can :manage, MobileApplication
      # can :create, InviteeStructure
      # can :manage, InviteeStructure
      can :read, InviteeStructure
      can :create, StoreInfo
      can :manage, StoreInfo
      can :create, StoreScreenshot
      can :manage, StoreScreenshot#, :client_id => c_ids
      can :create, Event
      can :manage, Event, :client_id => c_ids
      
      e_ids = Event.where(:client_id => c_ids).pluck(:id).uniq
      
      can :create, Chat
      can :manage, Chat, :event_id => e_ids
      can :create, InviteeGroup
      can :manage, InviteeGroup, :event_id => e_ids
      can :create, Agenda
      can :manage, Agenda, :event_id => e_ids
      can :create, Attendee
      can :manage, Attendee, :event_id => e_ids
      can :create, Invitee
      can :manage, Invitee, :event_id => e_ids
      can :create, Speaker
      can :manage, Speaker, :event_id => e_ids
      can :create, Poll
      can :manage, Poll, :event_id => e_ids
      can :create, Quiz
      can :manage, Quiz, :event_id => e_ids
      can :create, Panel
      can :manage, Panel, :event_id => e_ids
      can :create, Conversation
      can :manage, Conversation, :event_id => e_ids
      can :create, Sponsor
      can :manage, Sponsor, :event_id => e_ids
      can :create, Exhibitor
      can :manage, Exhibitor, :event_id => e_ids
      can :create, Qna
      can :manage, Qna, :event_id => e_ids
      can :create, Award
      can :manage, Award, :event_id => e_ids
      can :create, EventFeature
      can :manage, EventFeature, :event_id => e_ids
      can :create, Faq
      can :manage, Faq, :event_id => e_ids
      can :create, Image
      can :manage, Image, :event_id => e_ids
      can :create, EKit
      can :manage, EKit, :event_id => e_ids
      can :create, Import
      can :manage, Import, :event_id => e_ids

      can :create, Notification
      can :manage, Notification, :event_id => e_ids
      can :create, InviteeNotification
      can :manage, InviteeNotification, :event_id => e_ids
      # can :create, Grouping
      # can :manage, Grouping, :event_id => e_ids
      can :create, Registration
      can :manage, Registration

      can :create, MyTravel
      can :manage, MyTravel, :event_id => e_ids
      can :create, TrackLink
      can :manage, TrackLink, :event_id => e_ids

      s_ids = Speaker.where(:event_id => e_ids).pluck(:id).uniq
      can :manage, Rating, :ratable_id => s_ids, :ratable_type => 'Speaker'
      can :manage, Feedback#, :speaker_id => s_ids
      c_ids = Conversation.where(:event_id => e_ids)
      can :manage, Like, :likable_id => c_ids, :likable_type => 'Conversation'
      can :manage, Comment, :commentable_id => c_ids, :commentable_type => 'Conversation'
      
      p_ids = Poll.where(:event_id => e_ids)
      can :manage, UserPoll, :poll_id => p_ids
      
      a_ids = Award.where(:event_id => e_ids).pluck(:id).uniq
      can :manage, Winner#, :award_id => a_ids  
      
      can :manage, Theme, :licensee_id => user.get_licensee

      s_ids = Speaker.where(:event_id => e_ids).pluck(:id).uniq
      can :manage, Rating, :ratable_id => s_ids, :ratable_type => 'Speaker'
      # can :manage, Feedback, :speaker_id => s_ids

      c_ids = Conversation.where(:event_id => e_ids)
      can :manage, Like, :likable_id => c_ids, :likable_type => 'Conversation'
      can :manage, Comment, :commentable_id => c_ids, :commentable_type => 'Conversation'
      
      p_ids = Poll.where(:event_id => e_ids)
      can :manage, UserPoll, :poll_id => p_ids
      
      a_ids = Award.where(:event_id => e_ids).pluck(:id).uniq
      can :manage, Winner, :award_id => a_ids
      

      can :read, :all

      can :create, Theme
      can :edit, Theme#, :licensee_id => nil
      can :manage, Theme#, :licensee_id => user.get_licensee

    elsif user.has_role? :event_admin
      can :create, User
      can :manage, User, :licensee_id => user.get_licensee
      
      can :read, Client.with_role(:module_admin, user)
      c_ids = Client.with_role(:event_admin, user).pluck(:id)
      c_ids += Event.with_role(:event_admin, user).pluck(:client_id)
      c_ids = c_ids.uniq
      can :create, MobileApplication
      can :manage, MobileApplication
      # can :create, InviteeStructure
      # can :manage, InviteeStructure
      can :read, InviteeStructure
      can :create, StoreInfo
      can :manage, StoreInfo
      can :create, StoreScreenshot
      can :manage, StoreScreenshot#, :client_id => c_ids
      can :manage, Event#, :client_id => c_ids
      
      e_ids = Event.where(:client_id => c_ids).pluck(:id).uniq
      can :create, InviteeGroup
      can :manage, InviteeGroup, :event_id => e_ids
      can :create, Chat
      can :manage, Chat, :event_id => e_ids
      can :create, Agenda
      can :manage, Agenda, :event_id => e_ids
      can :create, Attendee
      can :manage, Attendee, :event_id => e_ids
      can :create, Invitee
      can :manage, Invitee, :event_id => e_ids
      can :create, Speaker
      can :manage, Speaker, :event_id => e_ids
      can :create, Poll
      can :manage, Poll, :event_id => e_ids
      can :create, Quiz
      can :manage, Quiz, :event_id => e_ids
      can :create, Panel
      can :manage, Panel, :event_id => e_ids
      can :create, Conversation
      can :manage, Conversation, :event_id => e_ids
      can :create, Sponsor
      can :manage, Sponsor, :event_id => e_ids
      can :create, Exhibitor
      can :manage, Exhibitor, :event_id => e_ids
      can :create, Qna
      can :manage, Qna, :event_id => e_ids
      can :create, Award
      can :manage, Award, :event_id => e_ids
      can :create, EventFeature
      can :manage, EventFeature, :event_id => e_ids
      can :create, Faq
      can :manage, Faq, :event_id => e_ids
      can :create, Image
      can :manage, Image, :event_id => e_ids
      can :create, EKit
      can :manage, EKit, :event_id => e_ids
      can :create, Import
      can :manage, Import, :event_id => e_ids
      # can :create, Grouping
      # can :manage, Grouping, :event_id => e_ids
      can :create, Registration
      can :manage, Registration

      can :create, Notification
      can :manage, Notification, :event_id => e_ids
      can :create, InviteeNotification
      can :manage, InviteeNotification, :event_id => e_ids

      can :create, MyTravel
      can :manage, MyTravel, :event_id => e_ids
      can :create, TrackLink
      can :manage, TrackLink, :event_id => e_ids

      s_ids = Speaker.where(:event_id => e_ids).pluck(:id).uniq
      can :manage, Rating, :ratable_id => s_ids, :ratable_type => 'Speaker'
      can :manage, Feedback#, :speaker_id => s_ids

      c_ids = Conversation.where(:event_id => e_ids)
      can :manage, Like, :likable_id => c_ids, :likable_type => 'Conversation'
      can :manage, Comment, :commentable_id => c_ids, :commentable_type => 'Conversation'
      
      p_ids = Poll.where(:event_id => e_ids)
      can :manage, UserPoll, :poll_id => p_ids
      
      a_ids = Award.where(:event_id => e_ids).pluck(:id).uniq
      can :manage, Winner#, :award_id => a_ids  
      
      can :manage, Theme, :licensee_id => user.get_licensee
      can :read, :all

      s_ids = Speaker.where(:event_id => e_ids).pluck(:id).uniq
      can :manage, Rating, :ratable_id => s_ids, :ratable_type => 'Speaker'
      # can :manage, Feedback, :speaker_id => s_ids

      c_ids = Conversation.where(:event_id => e_ids)
      can :manage, Like, :likable_id => c_ids, :likable_type => 'Conversation'
      can :manage, Comment, :commentable_id => c_ids, :commentable_type => 'Conversation'
      
      p_ids = Poll.where(:event_id => e_ids)
      can :manage, UserPoll, :poll_id => p_ids
      
      a_ids = Award.where(:event_id => e_ids).pluck(:id).uniq
      can :manage, Winner, :award_id => a_ids
      
      can :read, :all
      can :create, Theme
      can :edit, Theme#, :licensee_id => nil
      can :manage, Theme#, :licensee_id => user.get_licensee
    elsif user.has_role? :module_admin
      can :read, Client.with_role(:module_admin, user)
      c_ids = Client.with_role(:event_admin, user).pluck(:id)
      c_ids += Event.with_role(:event_admin, user).pluck(:client_id)
      c_ids = c_ids.uniq
      can :read, Event, :client_id => c_ids
      
      e_ids = Event.where(:client_id => c_ids).pluck(:id).uniq
      can :create, Chat
      can :manage, Chat, :event_id => e_ids
      can :create, InviteeGroup
      can :manage, InviteeGroup, :event_id => e_ids
      can :create, Agenda
      can :manage, Agenda, :event_id => e_ids
      can :create, Attendee
      can :manage, Attendee, :event_id => e_ids
      can :create, Invitee
      can :manage, Invitee, :event_id => e_ids
      can :create, Speaker
      can :manage, Speaker, :event_id => e_ids
      can :create, Poll
      can :manage, Poll, :event_id => e_ids
      can :create, Quiz
      can :manage, Quiz, :event_id => e_ids
      can :create, Panel
      can :manage, Panel, :event_id => e_ids
      can :create, Conversation
      can :manage, Conversation, :event_id => e_ids
      can :create, Sponsor
      can :manage, Sponsor, :event_id => e_ids
      can :create, Exhibitor
      can :manage, Exhibitor, :event_id => e_ids
      can :create, Qna
      can :manage, Qna, :event_id => e_ids
      can :create, Award
      can :manage, Award, :event_id => e_ids
      can :create, EventFeature
      can :manage, EventFeature, :event_id => e_ids
      can :create, Faq
      can :manage, Faq, :event_id => e_ids
      can :create, Image
      can :manage, Image, :event_id => e_ids
      can :create, EKit
      can :manage, EKit, :event_id => e_ids
      can :create, Import
      can :manage, Import, :event_id => e_ids
      # can :create, Grouping
      # can :manage, Grouping, :event_id => e_ids
      can :create, Notification
      can :manage, Notification, :event_id => e_ids
      can :create, InviteeNotification
      can :manage, InviteeNotification, :event_id => e_ids
      
      can :create, Registration
      can :manage, Registration
      
      s_ids = Speaker.where(:event_id => e_ids).pluck(:id).uniq
      can :manage, Rating, :ratable_id => s_ids, :ratable_type => 'Speaker'
      can :manage, Feedback#, :speaker_id => s_ids

      c_ids = Conversation.where(:event_id => e_ids)
      can :manage, Like, :likable_id => c_ids, :likable_type => 'Conversation'
      can :manage, Comment, :commentable_id => c_ids, :commentable_type => 'Conversation'
      
      p_ids = Poll.where(:event_id => e_ids)
      can :manage, UserPoll, :poll_id => p_ids
      
      a_ids = Award.where(:event_id => e_ids).pluck(:id).uniq
      can :manage, Winner#, :award_id => a_ids  
      
      can :manage, Theme, :licensee_id => user.get_licensee

      s_ids = Speaker.where(:event_id => e_ids).pluck(:id).uniq
      can :manage, Rating, :ratable_id => s_ids, :ratable_type => 'Speaker'
      # can :manage, Feedback, :speaker_id => s_ids

      c_ids = Conversation.where(:event_id => e_ids)
      can :manage, Like, :likable_id => c_ids, :likable_type => 'Conversation'
      can :manage, Comment, :commentable_id => c_ids, :commentable_type => 'Conversation'
      
      p_ids = Poll.where(:event_id => e_ids)
      can :manage, UserPoll, :poll_id => p_ids
      
      a_ids = Award.where(:event_id => e_ids).pluck(:id).uniq
      can :manage, Winner, :award_id => a_ids
      # can :create, InviteeStructure
      # can :manage, InviteeStructure
      can :read, InviteeStructure

      can :read, :all
      
    elsif user.has_role? :moderator
      can :read, Client.with_role(:moderator, user)
      c_ids = Client.with_role(:moderator, user).pluck(:id)
      c_ids += Event.with_role(:moderator, user).pluck(:client_id)
      c_ids = c_ids.uniq
      can :read, Event, :client_id => c_ids
      
      e_ids = Event.where(:client_id => c_ids).pluck(:id).uniq
      can :create, Agenda
      can :manage, Agenda, :event_id => e_ids
      can :create, Attendee
      can :manage, Attendee, :event_id => e_ids
      can :create, Invitee
      can :manage, Invitee, :event_id => e_ids
      can :create, Speaker
      can :manage, Speaker, :event_id => e_ids
      can :create, Poll
      can :manage, Poll, :event_id => e_ids
      can :create, Quiz
      can :manage, Quiz, :event_id => e_ids
      can :create, Panel
      can :manage, Panel, :event_id => e_ids
      can :create, Conversation
      can :manage, Conversation, :event_id => e_ids
      can :create, Sponsor
      can :manage, Sponsor, :event_id => e_ids
      can :create, Exhibitor
      can :manage, Exhibitor, :event_id => e_ids
      can :create, Qna
      can :manage, Qna, :event_id => e_ids
      can :create, Award
      can :manage, Award, :event_id => e_ids
      can :create, EventFeature
      can :manage, EventFeature, :event_id => e_ids
      can :create, Faq
      can :manage, Faq, :event_id => e_ids
      can :create, Image
      can :manage, Image, :event_id => e_ids
      can :create, EKit
      can :manage, EKit, :event_id => e_ids
      can :create, Import
      can :manage, Import, :event_id => e_ids
      # can :create, Grouping
      # can :manage, Grouping, :event_id => e_ids
      can :create, Notification
      can :manage, Notification, :event_id => e_ids
      can :create, InviteeNotification
      can :manage, InviteeNotification, :event_id => e_ids
      
      s_ids = Speaker.where(:event_id => e_ids).pluck(:id).uniq
      can :manage, Rating, :ratable_id => s_ids, :ratable_type => 'Speaker'
      can :manage, Feedback#, :speaker_id => s_ids

      c_ids = Conversation.where(:event_id => e_ids)
      can :manage, Like, :likable_id => c_ids, :likable_type => 'Conversation'
      can :manage, Comment, :commentable_id => c_ids, :commentable_type => 'Conversation'
      
      p_ids = Poll.where(:event_id => e_ids)
      can :manage, UserPoll, :poll_id => p_ids
      
      a_ids = Award.where(:event_id => e_ids).pluck(:id).uniq
      can :manage, Winner#, :award_id => a_ids  
      
      can :manage, Theme, :licensee_id => user.get_licensee

      s_ids = Speaker.where(:event_id => e_ids).pluck(:id).uniq
      can :manage, Rating, :ratable_id => s_ids, :ratable_type => 'Speaker'
      # can :manage, Feedback, :speaker_id => s_ids

      c_ids = Conversation.where(:event_id => e_ids)
      can :manage, Like, :likable_id => c_ids, :likable_type => 'Conversation'
      can :manage, Comment, :commentable_id => c_ids, :commentable_type => 'Conversation'
      
      p_ids = Poll.where(:event_id => e_ids)
      can :manage, UserPoll, :poll_id => p_ids
      
      a_ids = Award.where(:event_id => e_ids).pluck(:id).uniq
      can :manage, Winner, :award_id => a_ids
      # can :create, InviteeStructure
      # can :manage, InviteeStructure
      can :read, InviteeStructure

      can :read, :all

    elsif user.has_role? :event_manager
      can :update, Client.with_role(:event_manager, user)
      ids = Client.with_role(:event_manager, user).pluck(:id)
      ids += Event.with_role(:event_manager, user).pluck(:client_id)
      can :manage, Event, :client_id => ids.uniq
      can :manage, Agenda
      can :manage, Attendee
      can :manage, Invitee
      can :manage, Speaker
      #can :manage, Event.with_role(:event_manager, user)
      can :read, :all
    elsif user.has_role? :executive
      can :read, :all  
    elsif user.has_role? :event_executive# , :db_manager , :db_executive , :response_manager , :response_executive , :communication_manager , :communication_executive , :development_manager , :development_executive, :client_admin, :client_moderator
      #can :manage, Client.with_role(:event_executive, user)
      can :read, :all
    elsif user.has_role? :db_manager
      can :read, :all
      can :manage, [Speaker,Agenda,MyTravel,Feedback,Invitee,InviteeGroup,Quiz,Import,InviteeStructure,Grouping]
    elsif user.has_role? :db_executive
      can :read, :all
    elsif user.has_role? :response_manager
      can :read, :all
      can :manage, Campaign
      can :manage, Edm
      can :manage, Grouping
      can :manage, Registration
    elsif user.has_role? :response_executive
      can :read, :all
    elsif user.has_role? :communication_manager
      can :read, :all
    elsif user.has_role? :communication_executive
      can :read, :all
    elsif user.has_role? :development_manager
      can :read, :all
    elsif user.has_role? :development_executive
      can :read, :all
    elsif user.has_role? :client_admin
      can :read, :all
    elsif user.has_role? :client_moderator
      can :read, :all
    elsif user.has_role? :Client_Response_Manager
      can :read, :all
      can :manage, Registration      
    elsif user.has_role? :telecaller
      can :read, Client.with_role(:module_admin, user)
      c_ids = Client.with_role(:event_admin, user).pluck(:id)
      c_ids += Event.with_role(:event_admin, user).pluck(:client_id)
      c_ids = c_ids.uniq
      can :read, Event, :client_id => c_ids
      can :read, Client
      can :manage, InviteeDatum
    end

    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  end
end
