class Api::V1::QnasController < ApplicationController

	#skip_before_action :load_filter
	respond_to :json
	def create
		event = Event.find_by_id(params[:event_id])
		if event.present?
				ques_answer = event.qnas.new(question: params[:question], sender_id: mobile_current_user.id, receiver_id: params[:receiver_id])
				if ques_answer.save
					render :status=>200, :json=>{:status=>"Success",:message=>"Question & Answer Created Successfully."}
				else
					render :status=>401, :json=>{:status=>"Failure",:message=>"You need to pass these values: #{ques_answer.errors.full_messages.join(" , ")}"}
				end
		else
			render :status=>401, :json=>{:status=>"Failure",:message=>"Event Not Found."}
		end	
	end	

end
