class Api::V5::ConversationsController < ApplicationController
  skip_before_action :load_filter
  skip_before_action :authenticate_user!
  before_filter :check_for_event, :only => [:index, :create]
  before_filter :check_for_image, :only => [:create]
  before_filter :check_for_conversation, :only => [:show]
  respond_to :json 

  def create  
    if @conversation.save
      render :status=>406,:json=>{:status=>"Success",
                                  :message=>"Conversation Created Successfully.", 
                                  :id => @conversation.id,
                                  :visible_status => @conversation.status,
                                  :updated_at => @conversation.updated_at,
                                  :image_url => @conversation.image_url,
                                  :company_name => @conversation.company_name,
                                  :user_name => @conversation.user_name,
                                  :first_name => @conversation.user.first_name,
                                  :last_name => @conversation.user.last_name,
                                  :formatted_created_at_with_event_timezone => @conversation.formatted_created_at_with_event_timezone,
                                  :formatted_updated_at_with_event_timezone => @conversation.formatted_updated_at_with_event_timezone,
                                  :last_interaction_at => @conversation.updated_at,
                                  :actioner_id => @conversation.actioner_id}
    else
      render :status=>406,:json=>{:status=>"Failure",
                                  :message=>"You need to pass these values: #{@conversation.errors.full_messages.join(" , ")}" }
    end
  end

  def index
    data = Conversation.get_records(params)
    render :status => 200, :json => {:status => "Success",
                                     :conversation_sync_time => Time.now.utc.to_s,
                                     :page_no => params[:page],
                                     :data => data}
  end

  def show
    data = Conversation.get_likes_data(params) 
    render :json=>{:status=>200,
                   :data=>data,
                   :likes_count=>@conversation.likes.count}
  end  

  protected 
  def check_for_event
    event = Event.find_by_id(params[:event_id])
    if event.blank?
      render :status=>200, :json=>{:status=>"Failure", :message=>"Event Not Found."}
    end
  end
  def check_for_image
    event = Event.find_by_id(params[:event_id])
    if params[:image].present?
      @conversation = event.conversations.new(:description => params[:description], :image => params[:image].first, :user_id => params[:user_id] ) 
    else
      @conversation = event.conversations.new(:description => params[:description], :user_id => params[:user_id] ) 
    end
  end
  def check_for_conversation
    @conversation = Conversation.find_by_id(params[:id])
    if @conversation.blank?
      render :json=>{:status=>401, :message=>"invalid conversation id"}
    end  
  end
end
#url with pagination :- http://localhost:3000/api/v5//conversations.json?event_id=652&page=1
#url with out pagination :-  http://localhost:3000/api/v5//conversations.json?event_id=652