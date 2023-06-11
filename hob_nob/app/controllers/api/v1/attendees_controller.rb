class Api::V1::AttendeesController < ApplicationController
	respond_to :json 
	#skip_before_action :authenticate_user!
	def index
		client = Client.find_by_id(params[:client_id])
		if client.present?
			events = client.events
			event = events.where(:id => params[:event_id])
			if event.present?
				attendees = Attendee.where(:event_id => event.first.id) rescue []
				render :staus => 200, :json => {:status => "Success",:attendees => attendees.as_json() } rescue []
			else
				render :status => 406, :json => {:status => "Failure", :message => "Event Not Found."}
			end	
		else
			render :status => 406, :json => {:status => "Failure", :message => "Client Not Found."}
		end	
	end
end
