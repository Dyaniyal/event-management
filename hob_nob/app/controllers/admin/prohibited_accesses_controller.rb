class Admin::ProhibitedAccessesController < ApplicationController
  layout 'admin'

  #load_and_authorize_resource
  before_filter :authenticate_user
  before_filter :get_event_id

  def index
    @prohibited_accesses = []
  end

  protected
   
    def get_event_id
       @event_id = params[:event] if params[:event].present?
    end
end
