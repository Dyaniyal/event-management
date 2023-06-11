class Admin::TelecallerGroupsController < ApplicationController

	before_filter :authenticate_user
  def new
    #@telecaller_groups = TelecallerGroup.new
    @event = Event.find_by_id(params[:event_id])
		if params[:email].present?
      @email = params[:email].split('(').last.split(')').first
      @telecaller = User.where(:email => @email).first rescue []
      if @telecaller.present?
        @telecaller_group = TelecallerGroup.where(:event_id=>@event.id,:user_id=>@telecaller.id)
        if @telecaller_group.present?
				  @telecaller_group = @telecaller_group.first
				else	
        	@telecaller_group = TelecallerGroup.new
      	end
      else
        @telecaller = User.new
  			@telecaller_group = TelecallerGroup.new
      end
      #@role, @url = params[:role], params[:redirect_url]
    end
    respond_to do |format|
      format.js{}
      format.html{}
    end
	end	
end
