class Admin::LeaderboardsController < ApplicationController
	layout 'admin'
  before_filter :authenticate_user, :authorize_event_role
  before_filter :check_for_access, :only => [:index]
	
	def index
    if params[:top].present?
      @invitees = Invitee.invitee_with_thousand_or_more_points(@event.id)
      respond_to do |format|
        format.html  
        format.xls do
          only_columns = [:first_name, :last_name, :email, :designation, :company_name, :points]
          # method_allowed = [:invitee_with_thousand_or_more_points]
          send_data @invitees.to_xls(:only => only_columns)
        end
      end
    else
    @invitees = Invitee.unscoped.where(:event_id => @event.id, :visible_status => 'active').order('points desc')#.first(5)  
      respond_to do |format|
        format.html  
        format.xls do
          only_columns = [:first_name, :last_name, :email, :designation, :company_name, :points]
          method_allowed = [:rank]
          send_data @invitees.to_xls(:only => only_columns, :methods => method_allowed)
        end
      end
    end
	end
end
