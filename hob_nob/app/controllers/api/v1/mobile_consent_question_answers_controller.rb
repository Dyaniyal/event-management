class Api::V1::MobileConsentQuestionAnswersController < ApplicationController
  skip_before_action :load_filter
  before_filter :find_mobile, :only => [:new]
  before_filter :find_invitee, :only => [:new, :update]

  def index
  end

  def new
    @consent_questions = @mobile_application.mobile_consent_questions.first(10)
    @consent_question_look_and_feel = @mobile_application.consent_question_look_and_feel
  end

  def update
    if @invitee.update_attributes(invitee_params)
      respond_to do |format|
        format.js {render layout: false}
      end
    else
      respond_to do |format|
        format.js { }
      end
    end
  end
  
  protected
  def invitee_params
    params.require(:invitee).permit!
  end

  def find_mobile
    @mobile_application = MobileApplication.find_by_submitted_code(params[:mobile_application_code]) || MobileApplication.find_by_preview_code(params[:mobile_application_code])
  end

  def find_invitee
    @invitee = Invitee.find(params[:id])
  end
end
