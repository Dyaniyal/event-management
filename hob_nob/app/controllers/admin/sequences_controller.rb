class Admin::SequencesController < ApplicationController
  layout 'admin'
  before_filter :check_user_role
  before_filter :find_groups, :only => [:index, :create, :update]
  before_filter :authenticate_user, :authorize_event_role
  
  def update
    @event = Event.find_by_id(params[:event_id])
    feature_type = EventFeature.for_sequence_get_model_name[params[:feature_type]].constantize
    feature = feature_type.find_by_id(params[:id])
    @event.decide_seq_no(params[:seq_type],feature,feature_type)
    if feature_type == Winner
      winner = Winner.find_by_id(params[:id])
      @features = feature_type.where(:award_id => winner.award_id)
    elsif feature_type == Image
      if params[:from] == "microsites"
        microsite_feature = @event.microsite.microsite_features.where("name = ?", "images").first
        if params[:from] == "microsites" and microsite_feature.image_setting.downcase == 'yes'
          @folder = feature.folder
          @features = @folder.images if @folder.present?
        else
          @features = feature_type.where(:imageable_id => @event.id)
        end
      else
        event_feature = @event.event_features.where("name = ?", "galleries").first
        if event_feature.present? and event_feature.image_setting.downcase == 'yes'
          @folder = feature.folder
          @features = @folder.images if @folder.present?
        else
          @features = feature_type.where(:imageable_id => @event.id)
        end
      end
    elsif feature_type == Feedback
      @features = feature_type.where(:event_id => @event.id, :feedback_form_id => params["feedback_form_id"])
    else
      @features = feature_type.where(:event_id => @event.id)
    end
    @redirect_feature = params[:feature_type]
    instance_variable_set("@"+ params[:feature_type], @features)
    respond_to do |format|
      if @redirect_feature == "agenda_tracks"
        date = feature.agenda_date.strftime('%Y-%m-%d')
        path = "/admin/events/#{feature.event_id}/agendas"
        format.js{render :js => "window.location.href = '#{path}?d=#{date}'" }
      else  
        format.js{}
      end
      format.html{}
    end 
  end

  protected
    def find_groups
      @event = Event.find(params[:event_id])
      @groups = @event.invitee_groups
      @default_groups = []#@groups.where(:name => ['No Polls taken', 'No Feedback given', 'No Quiz taken', 'No Q&A Participation', 'No Participation in Conversations', 'No Favorites added'])
      @other_groups = @groups.where('name NOT IN (?)', ['No Polls taken', 'No Feedback given', 'No Quiz taken', 'No Q&A Participation', 'No Participation in Conversations', 'No Favorites added'])
    end
  
    def check_user_role
      @event = Event.find_by_id(params[:event_id])
      if (current_user.has_role_for_event?("db_manager", @event.id,session[:current_user_role])) 
        redirect_to admin_dashboards_path
      end  
    end
end