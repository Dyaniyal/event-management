class Admin::ConsentQuestionsController < ApplicationController
  layout 'admin'
  before_filter :authenticate_user, :authorize_event_role
  before_filter :find_event, :only => [:index, :new, :create]
  before_filter :find_consent_question, :only => [:show, :edit, :update, :destroy]
  
  def index
    @consent_questions = @event.consent_questions
  end

  def new
    @consent_question = @event.consent_questions.build
  end
  
  def create
    @consent_question = @event.consent_questions.build(consent_params)
    if @consent_question.save
      redirect_to admin_event_consent_questions_path
    else
      render :action => "new"
    end
  end


  def show
  end

  def edit
  end

  def update
    if @consent_question.update_attributes(consent_params)
      redirect_to admin_event_consent_questions_path
    else
      render :action => "edit"
    end
  end

  def destroy
    @consent_question.destroy
    redirect_to admin_event_consent_questions_path
  end

  private

  def consent_params
    params.require(:consent_question).permit!
  end

  def find_event
    @event = Event.find(params[:event_id])
  end
  
  def find_consent_question
    @consent_question = ConsentQuestion.find(params[:id])
  end
end
