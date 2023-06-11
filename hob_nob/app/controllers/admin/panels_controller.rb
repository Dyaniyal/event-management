class Admin::PanelsController < ApplicationController
	layout 'admin'

  load_and_authorize_resource
  before_filter :authenticate_user, :authorize_event_role, :find_features
  before_filter :check_qna_setting, :only => [:new,:create,:edit,:update]

  def index
    #@panels = Panel.search(params, @panels) if params[:search].present?
    @panels = @panels#.paginate(page: params[:page], per_page: 10)
	end

	def new
		@panel = @event.panels.build
		@speakers = @event.speakers
    @invitee = @event.invitees
	end

	def create
    if params[:panel_id].present? and params[:panel_id].first.present? #and params["panel"]["speaker_name"].blank?
      name = params["panel_id"].first == "0" ? params["panel"]["speaker_name"] : Speaker.find_by_id( params["panel_id"].first.to_i).speaker_name
      email = (params["panel"]["speaker_email"].present? ? params["panel"]["speaker_email"] : "")
  		@panel = @event.panels.new(name: name,panel_id: params["panel_id"].first.to_i, panel_type: params["panel_type"],speaker_email: email)
      if @panel.save
        redirect_to admin_event_panels_path(:event_id => @panel.event_id)
      else
        @speakers = @event.speakers
        @invitee = @event.invitees
        render :action => 'new'
      end
    else
      @speakers = @event.speakers
      @invitee = @event.invitees
      render :action => 'new'
    end
	end

	def edit
		@speakers = @event.speakers
    @invitee = @event.invitees
	end

	def update
		if params["hide_panel"].present? and params["hide_panel"] == "active"
      @panel.update_attribute("hide_panel","active") if @panel.present?
      redirect_to admin_event_panels_path(:event_id => @panel.event_id)
    elsif params[:panel_id].present? and params[:panel_id].first.present? #and params["panel"]["speaker_name"].blank?
      name = params["panel_id"].first == "0" ? params["panel"]["speaker_name"] : Speaker.find_by_id( params["panel_id"].first.to_i).speaker_name
      email = (params["panel"]["speaker_email"].present? ? params["panel"]["speaker_email"] : "")
      if @panel.update(name: name,panel_id: params["panel_id"].first.to_i, panel_type: params["panel_type"],speaker_email: email)
        redirect_to admin_event_panels_path(:event_id => @panel.event_id)
      else
        @speakers = @event.speakers
        @invitee = @event.invitees
        render :action => 'edit'
      end
    else
      @speakers = @event.speakers
      @invitee = @event.invitees
      render :action => 'edit'
    end
	end

	def show
  end

  def destroy
    if @panel.destroy
      redirect_to admin_event_panels_path(:event_id => @panel.event_id)
    end
  end
  protected
  def panel_params
    params.require(:panel).permit!
  end
  private
  def check_qna_setting
    @email_validation = @event.qna_settings.first
  end
end
