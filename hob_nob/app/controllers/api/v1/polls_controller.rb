class Api::V1::PollsController < ApplicationController
	#skip_before_action :load_filter
	respond_to :json

	def create
		poll = Poll.find_by_id(params[:poll_id])
		if poll.present?
		  answer = poll.user_polls.new(user_id: mobile_current_user.id, answer: params[:answer])
		  if answer.save
		  	render :status => 200, :json => {:status => "Success", :user_poll_id => answer.id, :poll_id => poll.id, :answer => answer.answer, :message => "Answer save successfully."}
		  else
		  	render :status => 200, :json => {:status => "Failure", :message => "#{answer.errors.full_messages.join(" , ")}"}
		  end
		else
			render :status => 200, :json => {:status => "Failure", :message => "Poll not found."}
		end
	end
end
