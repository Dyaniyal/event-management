class Admin::SpeakersController < ApplicationController
  layout 'admin'

  load_and_authorize_resource
  before_filter :authenticate_user, :authorize_event_role, :find_features
  before_filter :find_ratings, :only => [:index, :new]
  before_filter :check_for_access, :only => [:index,:new]
  before_filter :check_user_role, :except => [:index]
  before_filter :find_groups, :only => [:new, :create, :edit, :update]

  def index
    if not params[:search_keyword].present? and (params[:search].present? and params[:search][:designation].present? and params[:search][:designation] == "All") || (params[:search].present? and params[:search][:company_name].present? and params[:search][:company_name] == "All")
    else
      @speakers = Speaker.search(params, @speakers) if params[:search].present?
    end
    respond_to do |format|
      format.html  
      format.xls do
        if params[:export_type].present? and params[:export_type] == 'Feedback'
          #only_columns = [:comments]
          #method_allowed = [:speaker_name, :star_rating, :attendee_email, :attendee_name]
          only_columns = []
          method_allowed = [:Timestamp, :email_id, :first_name, :last_name, :speaker_name, :user_rating, :user_comment, :twitter_link, :linkedin_link,  :facebook_link, :google_link]
          send_data @feedbacks.to_xls(:only => only_columns, :methods => method_allowed)
        else
          only_columns = [:first_name, :last_name, :designation, :company, :phone_no, :email_address, :speaker_info, :twitter_link, :linkedin_link,  :facebook_link, :google_link, :rating_status]
          # method_allowed = [:profile_picture]
          send_data @speakers.to_xls(:only => only_columns)
        end
      end
    end
  end

  def new
    @speaker = @event.speakers.build
    @import = Import.new if params[:import].present?
  end

  def create
    @speaker = @event.speakers.build(speaker_params)
    if @speaker.save
      if params[:from] == "microsites"
        redirect_to admin_event_speakers_path(:event_id => @speaker.event_id, :from => "microsites")
      elsif params[:type].present?
        redirect_to admin_event_mobile_application_path(:event_id => @event.id,:id => @event.mobile_application_id,:type => "show_content")
      else
        redirect_to admin_event_speakers_path(:event_id => @speaker.event_id)
      end
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @speaker.update_attributes(speaker_params)
      if params[:from] == "microsites"
        redirect_to admin_event_speakers_path(:event_id => @speaker.event_id, :from => "microsites")
      else
        redirect_to admin_event_speakers_path(:event_id => @speaker.event_id)
      end
    else
      render :action => "edit"
    end
  end

  def show
  end

  def destroy
    if @speaker.destroy
      if params[:from] == "microsites"
        redirect_to admin_event_speakers_path(:event_id => @speaker.event_id, :from => "microsites")
      else
        redirect_to admin_event_speakers_path(:event_id => @speaker.event_id)
      end
    end
  end

  protected

  def find_ratings
    @feedbacks = Rating.where(:ratable_type => 'Speaker', :ratable_id => @speakers.pluck(:id)) if @speakers.present?
  end
  
  def find_groups
    @event = Event.find(params[:event_id])
    @groups = @event.invitee_groups
    @default_groups = []#@groups.where(:name => ['No Polls taken', 'No Feedback given', 'No Quiz taken', 'No Q&A Participation', 'No Participation in Conversations', 'No Favorites added'])
    @other_groups = @groups.where('name NOT IN (?)', ['No Polls taken', 'No Feedback given', 'No Quiz taken', 'No Q&A Participation', 'No Participation in Conversations', 'No Favorites added'])
  end

  def speaker_params
    params.require(:speaker).permit!
  end
  def check_user_role
    if (current_user.has_role_for_event?("db_manager", @event.id,session[:current_user_role]))
      redirect_to admin_dashboards_path
    end  
  end
end
