class Admin::LikesController < ApplicationController

  layout 'admin'
  load_and_authorize_resource
  before_filter :authenticate_user, :authorize_event_role, :find_features

  def index
    respond_to do |format|
      format.html  
      format.xls do
        method_allowed = [:conversation, :email, :user_name, :created_at]
        send_data @likes.to_xls(:methods => method_allowed)
      end
    end
  end

  private

  def find_features
    @conversations = @event.conversations
    @likes = Like.where(:likable_id => @conversations.pluck(:id), :likable_type => 'Conversation')# if params[:format].present?
  end

end
