class Admin::CommentsController < ApplicationController

  layout 'admin'
  load_and_authorize_resource
  before_filter :authenticate_user, :authorize_event_role, :find_features

  def index
    respond_to do |format|
      format.html  
      format.xls do
        method_allowed = [:conversation, :email, :user_name, :comment, :like_count,:timestamp]
        send_data @comments.includes(:commentable).to_xls(:methods => method_allowed)
      end
    end
  end

  private

  def find_features
    @conversations = @event.conversations
    @comments = Comment.where(:commentable_id => @conversations.pluck(:id), :commentable_type => 'Conversation')
  end

end
