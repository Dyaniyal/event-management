class Admin::UserQuizzesController < ApplicationController
  layout 'admin'
  # load_and_authorize_resource
  before_filter :authenticate_user, :authorize_event_role, :find_features
  before_filter :check_for_access, :only => [:index]
  before_filter :check_user_role, :except => [:index]

  def index
    respond_to do |format|
      format.html  
      format.xls do
        method_allowed = [:Timestamp, :email_id, :first_name, :last_name, :question, :user_answer, :correct_answer]
        send_data @user_quizes.includes(:quiz).to_xls(:methods => method_allowed)
      end
    end
  end

  private

  def find_features
    @quizes = @event.quizzes
    @user_quizes = UserQuiz.where(:quiz_id => @quizes.pluck(:id))# if params[:format].present?
  end
  def check_user_role
    if (current_user.has_role? :db_manager) 
      redirect_to admin_dashboards_path
    end  
  end

end