class Admin::NotificationActionChangesController < ApplicationController

  def index
    if params[:feature_name].present?
      feature_name = params[:feature_name].downcase.pluralize if params[:feature_name] != "E-Kit"
      feature_name = "e_kits" if params[:feature_name] == "E-Kit"
      event = Event.find(params[:event_id])
      if ["speakers","polls","quizzes","agendas","feedbacks"].include? feature_name
        @associated_data = instance_variable_set("@"+feature_name, event.send(feature_name))
        if feature_name == "feedbacks"
          feedback_form_ids = @associated_data.pluck(:feedback_form_id).uniq.compact
          if feedback_form_ids.present?
            @associated_data = FeedbackForm.where("id IN (?) and status = ? ",feedback_form_ids,"active")
          end
        elsif feature_name == "polls"
          @associated_data = @associated_data.where(:status => "activate")
        elsif feature_name == "quizzes"
          @associated_data = @associated_data.where(:status => "activate")
        end
      end
    end
  end
end
