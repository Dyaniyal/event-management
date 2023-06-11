class Admin::InviteeStructuresController < ApplicationController
  layout 'admin'

  #load_and_authorize_resource
  before_filter :authenticate_user, :authorize_event_role, :find_features, :find_invitee_data
  before_filter :check_for_access, :only => [:index,:new]
  before_filter :check_user_role#, :except => [:index] 
  
  def index
    if @invitee_structure.present?
      @invitee_data = @invitee_structure.invitee_datum
      respond_to do |format|
        if @invitee_structure.present? and params[:sample_download].present?
          format.xls do
            only_columns = @invitee_structure.attributes.except('id', 'created_at', 'updated_at', 'event_id', 'uniq_identifier','email_field','mandate_attr2','mandate_attr3','mandate_attr4','mandate_attr5','mandate_attr6','mandate_attr7','mandate_attr8','mandate_attr9','mandate_attr10','mandate_attr11','mandate_attr12','mandate_attr13','mandate_attr14','mandate_attr15','mandate_attr16','mandate_attr17','mandate_attr18','mandate_attr19','mandate_attr20','mandate_attr21','mandate_attr22','mandate_attr23','mandate_attr24','mandate_attr25','mandate_attr26','mandate_attr27','mandate_attr28','mandate_attr29','mandate_attr30','parent_id','multi_lng_parent_id','language_updated','expiry_date').map{|k, v| v.to_s.length > 0 ? v : nil}.compact
            @invitee_structure = InviteeStructure.where(:event_id => @event.id)
            send_data [only_columns].to_reports_xls
            # send_data @invitee_structure.to_xls(:only => only_columns,:only_export_column=>"true")
          end
        else
          # @invitee_data = @invitee_structure.invitee_datum#InviteeStructure.search(params, @invitee_structures) if params[:search].present?
          #@invitee_data = InviteeDatum.search(params, @invitee_data)
          format.html  
          format.xls do
            
          end
        end
      end
    else
      redirect_to new_admin_event_invitee_structure_path(:event_id => params[:event_id])
    end
  end

  def new
    @import = Import.new if params[:import].present?
    if @invitee_structures.present? and @import.blank?
      redirect_to edit_admin_event_invitee_structure_path(:event_id => @event.id, :id => @invitee_structure.id)
    else
      @invitee_structure = @event.invitee_structures.build
    end
  end

  def create
    @invitee_structure = @event.invitee_structures.build(invitee_structure_params)
    if @invitee_structure.save
      redirect_to admin_client_event_path(:client_id => @event.client_id, :id => @event.id)
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @invitee_structure.update_attributes(invitee_structure_params)
      redirect_to admin_event_invitee_structures_path(:event_id => @invitee_structure.event_id)
    else
      if @invitee_structure.errors.messages[:expiry_date].present?
        redirect_to edit_admin_event_invitee_structure_path(@event, @invitee_structure, setting: true)
      else
        render :action => "edit"
      end
    end
  end

  def show
    redirect_to edit_admin_event_invitee_structure_path(:event_id => @event.id, :id => @event.invitee_structures.first.id)
  end

  def destroy
    @invitee_data = InviteeDatum.find(params[:id])
    @invitee_structure = @invitee_data.invitee_structure
    if @invitee_data.destroy
      redirect_to admin_event_invitee_structures_path(:event_id => @invitee_structure.event_id)
    end
  end

  protected

  def find_invitee_data
    @invitee_structures = @event.invitee_structures if params[:action] != 'index'
    @invitee_structure = @invitee_structures.first if @invitee_structures.present?
    @groupings = @event.groupings
  end

  def invitee_structure_params
    if params[:invitee_structure].present?
      params.require(:invitee_structure).permit!
    else
      {}
    end
  end

  def check_user_role
    if !(current_user.has_role_for_event?("db_manager", @event.id,session[:current_user_role]) || current_user.has_role_for_event?("response_manager", @event.id,session[:current_user_role]))
      redirect_to admin_dashboards_path
    end  
  end
  
end
