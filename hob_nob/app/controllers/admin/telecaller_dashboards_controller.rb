class Admin::TelecallerDashboardsController < ApplicationController
	layout 'admin'
	before_filter :authenticate_user
	before_filter :find_event

	def index
    @invitee_data = @event.invitee_structures.first.invitee_datum.exclude_unsubcribes(@event) if @event.invitee_structures.present?
    if params[:user_id].present?
      @telecaller = User.find_by_id(params[:user_id])
      @telecaller_group = @telecaller.telecaller_groups.where(:event_id=>params[:event_id]).first
      @no_called = @telecaller.telecaller_report_count(@telecaller.id,@event, "not_called") 
      if params[:filter_date].present? and params[:filter_date] != "date range"		    
		    @achieved_number = @telecaller.telecaller_report_count(@telecaller.id,@event, "Assigned",params[:filter_date])
		    @registerd_status = @telecaller.telecaller_report_count(@telecaller.id,@event, "REGISTERED",params[:filter_date])
		    @hot_status = @telecaller.telecaller_report_count(@telecaller.id,@event, "HOT",params[:filter_date])
		    @warm_status = @telecaller.telecaller_report_count(@telecaller.id,@event, "WARM",params[:filter_date])
		    @regret_status = @telecaller.telecaller_report_count(@telecaller.id,@event, "REGRET",params[:filter_date])
	      @other_status = @telecaller.telecaller_report_count(@telecaller.id,@event, "OTHER",params[:filter_date])
	      @reopened_invitee_datum = @telecaller.telecaller_report_count(@telecaller.id,@event, "REOPEN",params[:filter_date])
      elsif params[:filter_date].present? and params[:filter_date] == "date range"
	    	@achieved_number = @telecaller.telecaller_report_count(@telecaller.id,@event, "Assigned",params[:start_date],params[:end_date])
		    @registerd_status = @telecaller.telecaller_report_count(@telecaller.id,@event, "REGISTERED",params[:start_date],params[:end_date])
		    @hot_status = @telecaller.telecaller_report_count(@telecaller.id,@event, "HOT",params[:start_date],params[:end_date])
		    @warm_status = @telecaller.telecaller_report_count(@telecaller.id,@event, "WARM",params[:start_date],params[:end_date])
		    @regret_status = @telecaller.telecaller_report_count(@telecaller.id,@event, "REGRET",params[:start_date],params[:end_date])
        @other_status = @telecaller.telecaller_report_count(@telecaller.id,@event, "OTHER",params[:start_date],params[:end_date])
        @reopened_invitee_datum = @telecaller.telecaller_report_count(@telecaller.id,@event, "REOPEN",params[:start_date],params[:end_date])
	    else
	    	@achieved_number = @telecaller.telecaller_report_count(@telecaller.id,@event, "Assigned")
		    @registerd_status = @telecaller.telecaller_report_count(@telecaller.id,@event, "REGISTERED")
		    @hot_status = @telecaller.telecaller_report_count(@telecaller.id,@event, "HOT")
		    @warm_status = @telecaller.telecaller_report_count(@telecaller.id,@event, "WARM")
		    @regret_status = @telecaller.telecaller_report_count(@telecaller.id,@event, "REGRET")
        @other_status = @telecaller.telecaller_report_count(@telecaller.id,@event, "OTHER")
        @reopened_invitee_datum = @telecaller.telecaller_report_count(@telecaller.id,@event, "REOPEN")
	    end	  	
	  elsif params[:from].present? and params[:from] == "dashboard"	   	
	    # @no_called = @invitee_data.where("status is null") if @invitee_data
	    @no_called = User.get_telecaller_assigned_records(@event).where(status: nil, invitee_data_updated: nil) rescue nil
      @telecaller_group = User.registration_target_data(@event)
	    @target_assigned = User.get_telecaller_assigned_data(@event)
	    @achieved_number = User.get_telecaller_achived_data(@event,@invitee_data,params)
	    @registerd_status = User.get_telecaller_registered_data(@event,@invitee_data,params)
	    @hot_status = User.get_telecaller_hot_data(@event,@invitee_data,params)
	    @warm_status = User.get_telecaller_warm_data(@event,@invitee_data,params)
	    @regret_status = User.get_telecaller_regret_data(@event,@invitee_data,params)
      @other_status = User.get_telecaller_other_data(@event,@invitee_data,params)
      @reopened_invitee_datum = User.get_reopened_data(@event,@invitee_data,params)
	  end
    @callback_data = User.get_callback_invitees(@invitee_data, @event, current_user.id).first
	end

	def show
		@invitee_structure = @event.invitee_structures.last
		columns = @invitee_structure.attributes.except('id','created_at','updated_at','event_id','uniq_identifier')
    @only_columns = @invitee_structure.get_selected_column + ["status","reported_status","telecaller_id","remark","invitee_data_updated","telecaller_update_count"]
    @header_columns = @only_columns.map{|c| columns[c]}.compact  + ["call status","Reported status","telecaller name","Remarks"]
    header_columns = @only_columns.map{|c| columns[c]}.compact  + ["call status","Reported status","telecaller name","Remarks","Last Call Date / Time", "Data Updated"]
		if @event.telecaller_accessible_columns.present?
			@header_columns = @header_columns && @event.telecaller_accessible_columns.first.accessible_attribute.values.flatten + ["call status","Reported status","telecaller name","Remarks"]
      header_columns = header_columns && @event.telecaller_accessible_columns.first.accessible_attribute.values.flatten + ["call status","Reported status","telecaller name","Remarks","Last Call Date / Time", "Data Updated"]
	  end
	  @invitee_data = @event.invitee_structures.first.invitee_datum.exclude_unsubcribes(@event) if @event.invitee_structures.present?
	  # @telecaller_data = @invitee_data.where("status is null") if @invitee_data	and (params[:status].present? and params[:status]=="un_called")
    @telecaller_data = User.get_telecaller_assigned_records(@event).where(status: nil, invitee_data_updated: nil) if @invitee_data and (params[:status].present? and params[:status]=="un_called")
	  @telecaller_data = User.get_telecaller_hot_data(@event,@invitee_data,params)  if @invitee_data	and (params[:status].present? and params[:status]=="hot")
	  @telecaller_data = User.get_telecaller_regret_data(@event,@invitee_data,params)  if @invitee_data	and (params[:status].present? and params[:status]=="regret")
	  @telecaller_data = User.get_telecaller_other_data(@event,@invitee_data,params)  if @invitee_data  and (params[:status].present? and params[:status]=="other")
    @telecaller_data = User.get_telecaller_warm_data(@event,@invitee_data,params)  if @invitee_data	and (params[:status].present? and params[:status]=="warm")
	  @telecaller_data = User.get_telecaller_registered_data(@event,@invitee_data,params)  if @invitee_data	and (params[:status].present? and params[:status]=="registered")
	  @telecaller_data = User.get_telecaller_achived_data(@event,@invitee_data,params) if @invitee_data	and (params[:status].present? and params[:status]=="assigned")
	  @telecaller_data = User.get_reopened_data(@event,@invitee_data,params) if @invitee_data	and (params[:status].present? and params[:status]=="reopened")
		respond_to do |format|
      format.html  
	      format.xls do
			    @invitee_datum = @telecaller_data 
			    @export_array = params[:status] == 'un_called' ? [@header_columns] : [header_columns]
			    method_allowed = []
          for invitee in @invitee_datum
			      if @event.telecaller_accessible_columns.present?
			      	if params[:status] == 'un_called'
                @only_columns = @only_columns && @event.telecaller_accessible_columns.first.accessible_attribute.keys.flatten + ["status","reported_status","telecaller_id","remark"]
              else
                @only_columns = @only_columns && @event.telecaller_accessible_columns.first.accessible_attribute.keys.flatten + ["status","reported_status","telecaller_id","remark","invitee_data_updated","telecaller_update_count"]
	           end
  		     	end
			     	arr = @only_columns.map{|c| c == "telecaller_update_count" ? invitee.telecaller_update_count.present? : (c == "telecaller_id" ? invitee.get_telecaller_name : invitee.attributes[c])}
            arr = arr.map{|x| x.class == ActiveSupport::TimeWithZone ? (x + @event.timezone_offset.to_i.seconds).strftime('%d/%m/%Y %I:%M%p') : x}
            arr = arr.map{|x| x == true ? 'Yes' : x == false ? 'No' : x}
            @export_array << arr
			    end
          send_data @export_array.to_reports_xls, filename: "telecaller_statistics.xls"
				end
    end
	end	

	def new
		event = Event.find(params[:event_id])
		invitee_data = event.invitee_structures.first.invitee_datum if event.invitee_structures.present?
		@callback_data = User.get_callback_invitees(invitee_data, event, current_user.id).first
		@callback_data = (@callback_data.present? and (params[:callback_id].to_i != @callback_data.id)) ? @callback_data : nil
	end

	protected
		
		def find_event
    	@event = Event.find(params[:event_id])
  	end

end
