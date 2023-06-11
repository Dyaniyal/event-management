class Api::V1::RatingsController < ApplicationController
	#skip_before_action :load_filter
	# skip_before_action :authenticate_user!
	respond_to :json 
	def create
    if (params[:ratable_type].present? and params[:rating].present?) and ["Agenda","Speaker","Sponsor"].include?(params[:ratable_type].capitalize)
      if params[:id].present? and params[:id] != 0 and params[:ratable_type] == "Sponsor"
        rating = Rating.find_by_id(params[:id])
        rating.update_attributes(:ratable_id => params[:ratable_id], :ratable_type => params[:ratable_type].capitalize, :rating => params[:rating], :out_of => params[:out_of], :comments => params[:comments], :rated_by => params[:rated_by])
      else
        rating = Rating.new(:ratable_id => params[:ratable_id], :ratable_type => params[:ratable_type].capitalize, :rating => params[:rating], :out_of => params[:out_of], :comments => params[:comments], :rated_by => params[:rated_by])
      end
	  	if rating.save
				render :status => 200, :json => {:status => "Success", :message => "Ratings Successfully Created."}
			else
				render :status => 200, :json => {:status => "Failure", :message => "You need to pass the Fields: #{rating.errors.full_messages.join(" , ")}." }	
			end
		else
				render :status => 200, :json => {:status => "Failure", :message => "check Rating type it must be either agenda or Speaker or Sponsor, Rating can't be blank"}	
		end	
  end
end