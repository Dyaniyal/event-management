class AddLanguageUpdatedToModels < ActiveRecord::Migration
  def change
  	add_column :microsites, :language_updated, :boolean, default: false
  	add_column :speakers, :language_updated, :boolean, default: false
  	#add_column :event_venues, :language_updated, :boolean, default: false
  	add_column :invitees, :language_updated, :boolean, default: false
  	add_column :agendas, :language_updated, :boolean, default: false
  	add_column :faqs, :language_updated, :boolean, default: false
  	add_column :qnas, :language_updated, :boolean, default: false
  	add_column :conversations, :language_updated, :boolean, default: false
  	add_column :polls, :language_updated, :boolean, default: false
  	add_column :awards, :language_updated, :boolean, default: false
  	add_column :sponsors, :language_updated, :boolean, default: false
  	add_column :feedbacks, :language_updated, :boolean, default: false
  	add_column :feedback_forms, :language_updated, :boolean, default: false
  	add_column :images, :language_updated, :boolean, default: false
  	add_column :panels, :language_updated, :boolean, default: false
  	add_column :event_features, :language_updated, :boolean, default: false
  	add_column :e_kits, :language_updated, :boolean, default: false
  	add_column :contacts, :language_updated, :boolean, default: false
  	add_column :notifications, :language_updated, :boolean, default: false
  	add_column :highlight_images, :language_updated, :boolean, default: false
  	add_column :groupings, :language_updated, :boolean, default: false
  	add_column :quizzes, :language_updated, :boolean, default: false
  	add_column :invitee_structures, :language_updated, :boolean, default: false
  	add_column :exhibitors, :language_updated, :boolean, default: false
  	add_column :registration_settings, :language_updated, :boolean, default: false
  	add_column :registrations, :language_updated, :boolean, default: false
  	add_column :user_registrations, :language_updated, :boolean, default: false
  	add_column :custom_page1s, :language_updated, :boolean, default: false
  	add_column :custom_page2s, :language_updated, :boolean, default: false
  	add_column :custom_page3s, :language_updated, :boolean, default: false
  	add_column :custom_page4s, :language_updated, :boolean, default: false
  	add_column :custom_page5s, :language_updated, :boolean, default: false
  	add_column :chats, :language_updated, :boolean, default: false
  	add_column :invitee_groups, :language_updated, :boolean, default: false
  	add_column :my_travels, :language_updated, :boolean, default: false
  	add_column :telecaller_accessible_columns, :language_updated, :boolean, default: false
  	#add_column :venue_sections, :language_updated, :boolean, default: false
  	add_column :agenda_tracks, :language_updated, :boolean, default: false
  	add_column :manage_invitee_fields, :language_updated, :boolean, default: false
  	#add_column :my_travel_docs, :language_updated, :boolean, default: false
  	#add_column :courses, :language_updated, :boolean, default: false
  	add_column :qna_settings, :language_updated, :boolean, default: false
  	add_column :registration_look_and_feels, :language_updated, :boolean, default: false
  	add_column :track_links, :language_updated, :boolean, default: false
  	add_column :telecaller_groups, :language_updated, :boolean, default: false
  	add_column :emergency_exits, :language_updated, :boolean, default: false
  	add_column :qna_walls, :language_updated, :boolean, default: false
  	add_column :conversation_walls, :language_updated, :boolean, default: false
  	add_column :poll_walls, :language_updated, :boolean, default: false
  	add_column :quiz_walls, :language_updated, :boolean, default: false
  	add_column :badge_pdfs, :language_updated, :boolean, default: false
  	add_column :smtp_settings, :language_updated, :boolean, default: false
  	add_column :favorites, :language_updated, :boolean, default: false
  	add_column :analytics, :language_updated, :boolean, default: false
  	#add_column :course_providers, :language_updated, :boolean, default: false
    add_column :winners, :language_updated, :boolean, default: false
    add_column :my_profiles, :language_updated, :boolean, default: false
    add_column :edms, :language_updated, :boolean, default: false
  	add_column :campaigns, :language_updated, :boolean, default: false
  end
end
