class Admin::UserPollsController < ApplicationController

  layout 'admin'
  load_and_authorize_resource
  before_filter :authenticate_user, :authorize_event_role, :find_features
  before_filter :check_for_access, :only => [:index]

  def index
    respond_to do |format|
      format.html  
      format.xls do
        method_allowed = [:Timestamp, :email_id, :first_name, :last_name, :question, :user_answer,:Session_name]
        send_data @user_polls.includes(:poll).to_xls(:methods => method_allowed)
      end
    end
  end

  private

  def find_features
    @polls = @event.polls
    @user_polls = UserPoll.where(:poll_id => @polls.pluck(:id))# if params[:format].present?
  end

end
