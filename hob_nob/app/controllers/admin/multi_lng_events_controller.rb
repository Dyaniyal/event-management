class Admin::MultiLngEventsController < ApplicationController
  layout 'admin'

  #load_and_authorize_resource# :except => [:create]
  before_filter :authenticate_user, :get_event
  # before_filter :authorize_client_role, :find_client_association
  # before_filter :check_moderator_role, :feature_redirect_on_condition, :only => [:index]


  def index
    @multi_lng_events = Event.where(:parent_id => @event.id).paginate(page: params[:page], per_page: 10)
  end

  def update
    if params[:status].present?
      multi_event = Event.find(params[:id]) 
      if multi_event.primary_language.nil?
        multi_event.primary_language = 'english'
      end
      multi_event.status = 'rejected'
      multi_event.save
      redirect_to admin_event_multi_lng_events_path(:event_id => @event.id)
    end
  end

  protected
    def get_client
      if params[:client_id].present?
        @client = Client.find(params[:client_id])
      end
    end

    def get_event
      @event = Event.find_by_id(params[:event_id])
    end
end


