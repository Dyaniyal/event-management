class Admin::OnsiteAccessibleColumnsController < ApplicationController

  layout 'admin'

  #load_and_authorize_resource
  before_filter :authenticate_user, :authorize_event_role, :find_features, :check_for_access

  def new
    if @event.onsite_accessible_columns.present?
      redirect_to edit_admin_event_onsite_accessible_column_path(event_id: @event.id, id: @event.onsite_accessible_columns.first.id)
    else
      @onsite_accessible_column = @event.onsite_accessible_columns.build
      @registration_fields = @event.onsite_registration_fields
    end
  end

  def create
    @onsite_accessible_column = @event.onsite_accessible_columns.build(onsite_accessible_column_params)
    if @onsite_accessible_column.save
      redirect_to admin_event_onsite_registrations_path(event_id: @event.id) 
    else
      @registration_fields = @event.onsite_registration_fields
      render action: 'new'
    end
  end

  def edit
    @registration_fields = @event.onsite_registration_fields
  end

  def update
    if @onsite_accessible_column.update_attributes(onsite_accessible_column_params)
      redirect_to admin_event_onsite_registrations_path(event_id: @event.id)
    else
      @registration_fields = @event.onsite_registration_fields
      render action: "edit"
    end
  end

  protected

  def onsite_accessible_column_params
    if params[:onsite_accessible_column].present? 
      params.require(:onsite_accessible_column).permit!
    else
      {"accessible_attribute"=>{}}
    end
  end

end