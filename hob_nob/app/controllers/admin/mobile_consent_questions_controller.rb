class Admin::MobileConsentQuestionsController < ApplicationController
  layout 'admin'
  before_filter :authenticate_user, :authorize_event_role
  before_filter :find_mobile_application, :only => [:index, :new, :create, :edit, :update, :destroy]
  before_filter :find_consent_question, :only => [:show, :edit, :update, :destroy]
  
  def index
    @mobile_consent_questions = @mobile_application.mobile_consent_questions
  end

  def new
    @mobile_consent_question = @mobile_application.mobile_consent_questions.build
  end
  
  def create
    @mobile_consent_question = @mobile_application.mobile_consent_questions.build(consent_params)
    if @mobile_consent_question.save
      redirect_to admin_event_mobile_application_mobile_consent_questions_path(:event_id => @event.id, :mobile_application_id => @mobile_application.id)
    else
      render :action => "new"
    end
  end


  def show
  end

  def edit
  end

  def update
    if @mobile_consent_question.update_attributes(consent_params)
      redirect_to admin_event_mobile_application_mobile_consent_questions_path(:event_id => @event.id, :mobile_application_id => @mobile_application.id)
    else
      render :action => "edit"
    end
  end

  def destroy
    @mobile_consent_question.destroy
    redirect_to admin_event_mobile_application_mobile_consent_questions_path(:event_id => @event.id, :mobile_application_id => @mobile_application.id)
  end

  private

  def consent_params
    params.require(:mobile_consent_question).permit!
  end

  def find_mobile_application
    @mobile_application = MobileApplication.find(params[:mobile_application_id])
  end
  
  def find_consent_question
    @mobile_consent_question = MobileConsentQuestion.find(params[:id])
  end
end