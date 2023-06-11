class Admin::UserQnasController < ApplicationController
  #layout 'admin'
  #load_and_authorize_resource
  # before_filter :authenticate_user, :authorize_event_role#, :find_features
  skip_before_filter :authenticate_user
  skip_before_action :load_filter
  before_filter :find_event,:find_qna
  
  def index
  end

  def new
    @qnas = @receiver_qnas
  end

  def create
    @qna = Qna.find(params[:qna][:id])
    if @qna.update_attributes(qna_params)
      respond_to do |format|
        format.js {}
      end
    else
      respond_to do |format|
        format.js {}
      end
      #render :action => 'new'
    end
  end

  private

  def qna_params
    params.require(:qna).permit!
  end

  def find_qna
    if (params["rid"].present? and params["sid"].present?) or (params[:qna].present? and params[:qna][:rid] and params[:qna][:sid].present?)
      if (params["action"].present? and params["action"] == "create")
        @receiver_qnas = Panel.find(params[:qna][:rid]).received_questions.where(:sender_id => params[:qna][:sid]).where(:user_answered => 'no')
      else
        @receiver_qnas = Panel.find(params["rid"]).received_questions.where(:sender_id => params["sid"]).where(:user_answered => 'no')
        @receiver_answered_qnas = Panel.find(params["rid"]).received_questions.where(:sender_id => params["sid"]).where(:user_answered => 'yes')
      end
    end
  end

  def find_event
    if params[:event_id].present?
      @event = Event.find(params[:event_id])
    end
  end

end
