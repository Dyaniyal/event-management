class Api::V1::ChatsController < ApplicationController
	respond_to :json 

  def index
  	event = Event.find_by_id(params[:event_id])
    if event.present?
      member = Invitee.find_by_id(params[:member_ids])
      member_first_name = member.first_name rescue ''
      member_last_name = member.last_name rescue ''
  		chats = event.chats.where('sender_id = ? and member_ids = ? or sender_id = ? and member_ids = ?', params[:sender_id], params[:member_ids], params[:member_ids], params[:sender_id]).where('id > ?', params[:id].to_i)
  		@current_user_recieved_chats = event.chats.where("event_id = ? and member_ids = ? and sender_id = ? and unread = ?", params[:event_id], params[:sender_id], params[:member_ids],true) 
      if @current_user_recieved_chats.present?
        @current_user_recieved_chats.each do |chat|
          chat.update(:unread => false, :updated_at => Time.now)
        end 
      end
      # render :status => 200, :json => {:status => "Success", :member_first_name => member_first_name, :member_last_name => member_last_name, :chats => chats.as_json(:except => [:created_at, :updated_at])}
      render :status => 200, :json => {:status => "Success", :member_first_name => member_first_name, :member_last_name => member_last_name, :chats => chats.as_json(:except => [:created_at, :updated_at], :methods => [:created_at_with_event_timezone, :updated_at_with_event_timezone])}
  	else
  		render :status=>200, :json=>{:status=>"Failure",:message=>"Event Not Found."}
  	end
  end

  def create
  	event = Event.find_by_id(params[:event_id])
  	if params[:message].blank? or params[:sender_id].blank? or params[:member_ids].blank?
      render :status=>200,:json=>{:status=>"Failure",:message=>"The request must contain the sender_id, receiver_id, member_ids."}
      return
    end
    if event.present?
  		chat = event.chats.new(:chat_type => params[:chat_type], :sender_id => params[:sender_id], :member_ids => params[:member_ids], :message => params[:message], :platform => params[:platform])
  		if chat.save
  		  render :status=> 200, :json=>{:status=> "Success",:message=>"chat Created Successfully.", :chat => chat.as_json(:only => [:id, :message, :sender_id, :member_ids, :event_id])}
  		else
  			render :status=>200, :json=>{:status=>"Failure",:message=>"You need to pass these values: #{chat.errors.full_messages.join(" , ")}"}
  		end	
  	else
  		render :status=>200, :json=>{:status=>"Failure",:message=>"Event Not Found."}
  	end
  end


  def update_chat_read_status
    if params[:member_id].present? and params[:sender_id].present? and params[:event_id].present?
      @chats = Chat.where("event_id = ? and member_ids = ? and sender_id = ? and unread = ?", params[:event_id], params[:member_id], params[:sender_id],true) 
      if @chats.present?
        @chats.each do |chat|
          chat.update(:unread => false, :updated_at => Time.now)
        end  
        render :status=> 200, :json=>{:status=> "Success",:message=>"chat Updated Successfully."} 
      else
        render :status=>200, :json=>{:status=>"Success",:message=>" no unread chats found."}
      end
    else
      render :status=>200, :json=>{:status=>"Failure",:message=>"please send all required parameters."}
    end
  end

  def update
    chat = Chat.find_by_id(params[:id])
    if chat.present?
      if chat.update(:chat_type => params[:chat_type], :sender_id => params[:sender_id], :member_ids => params[:member_ids])
        render :status=> 200, :json=>{:status=> "Success",:message=>"chat Updated Successfully."}
      else
        render :status=>200, :json=>{:status=>"Failure",:message=>"You need to pass these values: #{chat.errors.full_messages.join(" , ")}"}
      end 
    else
      render :status=>200, :json=>{:status=>"Failure",:message=>"Chat Not Found."}
    end
  end

end