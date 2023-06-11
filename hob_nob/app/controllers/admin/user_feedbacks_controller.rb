class Admin::UserFeedbacksController < ApplicationController

  layout 'admin'
  load_and_authorize_resource
  before_filter :authenticate_user, :authorize_event_role, :find_features
  before_filter :check_for_access, :only => [:index]

  def index
    respond_to do |format|
      format.html  
      format.xls do
        method_allowed = [:Timestamp, :email, :first_name, :last_name, :Question, :user_answer, :Description]
        send_data @user_feedbacks.includes(:feedback).to_xls(:methods => method_allowed)
      end
    end
  end

  private

  def find_features
    #@feedbacks = @event.feedbacks
    @feedbacks = @event.feedbacks.where(:feedback_form_id=>params[:feedback_form_id])
    @user_feedbacks = UserFeedback.where(:feedback_id => @feedbacks.pluck(:id))
  end
end
