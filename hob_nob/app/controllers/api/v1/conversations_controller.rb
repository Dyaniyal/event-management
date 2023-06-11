class Api::V1::ConversationsController < ApplicationController
  skip_before_action :load_filter
  skip_before_action :authenticate_user!
  caches_action :index, :cache_path => Proc.new { |c| c.params["event_id"].to_s+c.params["previous_date_time"] }, :expires_in => 1.minutes.to_i

  respond_to :json 
  def create
    event = Event.find_by_id(params[:event_id])
    if event.present?
      if params[:image].present?
        conversation = event.conversations.new(:description => params[:description], :image => params[:image].first, :user_id => params[:user_id] ) 
      else
        conversation = event.conversations.new(:description => params[:description], :user_id => params[:user_id] ) 
      end
      if conversation.save
        conversation.update_column('last_interaction_at',conversation.updated_at)
        render :status=>406,:json=>{:status=>"Success",:message=>"Conversation Created Successfully.", :id => conversation.id, :visible_status => conversation.status, :updated_at => conversation.updated_at, :image_url => conversation.image_url, :company_name => conversation.company_name, :user_name => conversation.user_name, :first_name => conversation.user.first_name, :last_name => conversation.user.last_name, :formatted_created_at_with_event_timezone => conversation.formatted_created_at_with_event_timezone, :formatted_updated_at_with_event_timezone => conversation.formatted_updated_at_with_event_timezone, :last_interaction_at => conversation.last_interaction_at, :actioner_id => conversation.actioner_id}
      else
        render :status=>406,:json=>{:status=>"Failure",:message=>"You need to pass these values: #{conversation.errors.full_messages.join(" , ")}" }
      end
    else
      render :status=>406,:json=>{:status=>"Failure",:message=>"Event Not Found."}
    end
  end

  def index
    event = Event.find_by_id(params[:event_id])
    event = event.is_parent? ? event : Event.find_by_id(event.parent_id) if event.present?
    if event.present?
      data = {}
      sync_time = Time.now.utc.to_s
      start_event_date = params[:previous_date_time].present? ? (params[:previous_date_time]) : "01/01/1990 13:26:58".to_time.utc
      end_event_date = Time.now.utc + 2.minutes
      conversations = event.conversations.where(:updated_at => start_event_date..end_event_date, :status => 'approved').last(500) rescue []
      data[:'conversations'] = conversations.as_json(:except => [:image_file_name, :image_content_type, :image_file_size, :image_updated_at], :methods => [:image_url,:company_name,:like_count,:user_name,:comment_count, :formatted_created_at_with_event_timezone, :formatted_updated_at_with_event_timezone, :first_name, :last_name, :share_count, :profile_pic_url])
      conversation_ids = conversations.map(&:id) rescue []
      info = Comment.where(:commentable_id => conversation_ids, commentable_type: "Conversation", :updated_at => start_event_date..end_event_date) rescue []
      data[:'comments'] = info.as_json(:only => [:id, :commentable_id, :commentable_type, :user_id, :description, :created_at, :updated_at], :methods => [:user_name, :formatted_created_at_with_event_timezone, :formatted_updated_at_with_event_timezone, :first_name, :last_name]) rescue []
      render :status => 200, :json => {:status => "Success", :conversation_sync_time => sync_time, :data => data}
    else
      render :status=>200, :json=>{:status=>"Failure",:message=>"Event Not Found."}
    end
  end

  def show
    conversation = Conversation.find_by_id(params[:id])
    if conversation.present?
      likes_data = conversation.likes.as_json(:methods => [:user_name, :first_name, :last_name])
      render :json=>{:status=>200, :data=>likes_data,:likes_count=>conversation.likes.count}
    else
      render :json=>{:status=>401, :message=>"invalid conversation id"}
    end  
  end  
end
