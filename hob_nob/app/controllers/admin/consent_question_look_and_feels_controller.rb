class Admin::ConsentQuestionLookAndFeelsController < ApplicationController
	layout 'admin'
  before_filter :authenticate_user, :authorize_event_role
  before_filter :find_mobile_application, :only => [:new, :create, :edit, :update, :destroy]
  before_filter :find_look_and_feel, :only => [:show, :edit, :update, :destroy]
  

  def new
    if @mobile_application.consent_question_look_and_feel.nil?
      @consent_question_look_and_feel = @mobile_application.build_consent_question_look_and_feel
    else
      redirect_to edit_admin_event_mobile_application_consent_question_look_and_feel_path(:event_id => @event.id, :mobile_application_id => @mobile_application.id, :id => @mobile_application.consent_question_look_and_feel.id)
    end
  end
  
  def create
    @consent_question_look_and_feel = @mobile_application.build_consent_question_look_and_feel(consent_params)
    if @consent_question_look_and_feel.save
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
    if @consent_question_look_and_feel.update_attributes(consent_params)
      redirect_to admin_event_mobile_application_mobile_consent_questions_path(:event_id => @event.id, :mobile_application_id => @mobile_application.id)
    else
      render :action => "edit"
    end
  end

  def destroy
    @consent_question_look_and_feel.destroy
    redirect_to admin_event_mobile_application_mobile_consent_questions_path(:event_id => @event.id, :mobile_application_id => @mobile_application.id)
  end

  private

  def consent_params
    params.require(:consent_question_look_and_feel).permit!
  end

  def find_mobile_application
    @mobile_application = MobileApplication.find(params[:mobile_application_id])
  end
  
  def find_look_and_feel
    @consent_question_look_and_feel = ConsentQuestionLookAndFeel.find(params[:id])
  end
end
