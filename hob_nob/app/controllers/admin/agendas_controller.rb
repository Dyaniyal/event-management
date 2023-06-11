class Admin::AgendasController < ApplicationController
  layout 'admin'

  load_and_authorize_resource
  before_filter :authenticate_user, :authorize_event_role, :find_features
  before_filter :find_ratings, :only => [:index, :new]
  before_filter :check_for_access, :only => [:index,:new]
  before_filter :check_user_role, :except => [:index]
  before_filter :find_groups, :only => [:new, :create, :edit, :update]

  def index
    @agenda_group_by_start_agenda_time = @agendas.group("date(start_agenda_date)")
    @agenda_having_no_date = @agendas.where("start_agenda_time is null")
    @page = params[:controller].split("/").second
    @event_feature = @event.event_features.where(:name => @page)
    respond_to do |format|
      format.html  
      format.xls do
        only_columns = []
        method_allowed = [:Timestamp, :email_id, :first_name, :last_name, :session_name, :speaker_name,:star_rating,:user_comment]
        send_data @feedbacks.to_xls(:only => only_columns, :methods => method_allowed)
      end
    end
  end

  def new
    agenda_data = Agenda.find(params[:id]) rescue Agenda.new
    @agenda = @event.agendas.build(agenda_data.attributes.except('id', 'created_at', 'updated_at', 'start_agenda_time', 'end_agenda_time'))
    @spearkers = @event.speakers
    @import = Import.new if params[:import].present?
  end
  
  def create
    @agenda = @event.agendas.build(agenda_params)
    @agenda_track_new = AgendaTrack.set_agenda_track(params)
    @agenda.agenda_track_id = @agenda_track_new.id if @agenda_track_new.present?
    if @agenda.save
      if params[:from] == "microsites"
        redirect_to admin_event_microsite_path(:event_id => @event.id, :id => @event.microsite.id, :type => "show_content")
      elsif params[:type].present?
        redirect_to admin_event_mobile_application_path(:event_id => @event.id,:id => @event.mobile_application_id,:type => "show_content")
      else
        redirect_to admin_event_agendas_path(:event_id => @agenda.event_id)
      end
    else
      render :action => 'new'
    end
  end


  def edit
  end

  def update
    @agenda.update_column(:end_agenda_time, nil) if params[:agenda][:end_time_hour].blank? and params[:agenda][:end_time_minute].blank? and params[:agenda][:end_time_am].blank?
      @agenda_track_new = AgendaTrack.set_agenda_track(params)
    params[:agenda]["speaker_ids"] = nil if !params[:agenda].key?(:speaker_ids)
    if @agenda.update_attributes(agenda_params)
      if params[:from] == "microsites"
        redirect_to admin_event_agendas_path(:event_id => @agenda.event_id, :from => "microsites")
      else
        @agenda.update_column('agenda_track_id',@agenda_track_new.id) if @agenda_track_new.present? 
        redirect_to admin_event_agendas_path(:event_id => @agenda.event_id)
      end
    else
      render :action => "edit"
    end
  end

  def show
  end

  def destroy
    if @agenda.destroy
      if params[:from] == "microsites"
        redirect_to admin_event_agendas_path(:event_id => @agenda.event_id, :from => "microsites")
      else 
        redirect_to admin_event_agendas_path(:event_id => @agenda.event_id)
      end
    end
  end

  protected
  def find_groups
    @event = Event.find(params[:event_id])
    @groups = @event.invitee_groups
    @default_groups = []
    @other_groups = @groups.where('name NOT IN (?)', ['No Polls taken', 'No Feedback given', 'No Quiz taken', 'No Q&A Participation', 'No Participation in Conversations', 'No Favorites added'])
  end
  
  def find_ratings
    @feedbacks = Rating.where(:ratable_type => 'Agenda', :ratable_id => @agendas.pluck(:id)) if @agendas.present?
  end

  def agenda_params
    if params[:agenda][:start_agenda_time].present?
      params["agenda"]["start_agenda_time"].to_time
    end
    params.require(:agenda).permit!
  end
  def check_user_role
    if (current_user.has_role_for_event?("db_manager", @event.id,session[:current_user_role]))
      redirect_to admin_dashboards_path
    end  
  end
end
