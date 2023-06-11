class Api::V1::CommentsController < ApplicationController
	respond_to :json 
	def create
		conversation = Conversation.find_by_id(params[:conversation_id])
		if conversation.present?
			comment = conversation.comments.new(user_id: mobile_current_user.id, description: params[:description])
			if comment.save
				render :status=>200,:json=>{:status=>"Success",:message=>"comment Created Successfully." }
			else
				render :status=>406,:json=>{:status=>"Failure",:message=>"You need to pass these values: #{comment.errors.full_messages.join(" , ")}" }
			end
		else
			render :status=>406,:json=>{:status=>"Failure",:message=>"Conversation Not Found."}
		end
	end 
end
