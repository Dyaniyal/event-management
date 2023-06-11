class Api::V1::UserFeedbacksController < ApplicationController
	
	respond_to :json

	def create
		data = {}
		if params["userfeedbacks"].present?
			params["userfeedbacks"].each do |userfeedback|
				feedback = UserFeedback.new(params_userfeedback(userfeedback))
				if not(feedback.save)
					render :status => 406, :json => {:status => "Failure", :message => "You need to pass these values: #{feedback.errors.full_messages.join(" , ")} for #{feedback.feedback_id}"}
					return
				end
			end
			render :status=>200, :json=>{:status=>"Success",:message=>"Feedback Created Successfully."}
		else
			render :status => 406, :json => {:status => "Failure", :message => "Provide Correct Data."}
		end
	end

	protected

	def params_userfeedback(value)
		value.permit!
	end
end
