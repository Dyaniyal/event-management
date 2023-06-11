class Admin::TelecallerAccessibleColumnsController < ApplicationController
  layout 'admin'

  #load_and_authorize_resource
  before_filter :authenticate_user, :authorize_event_role, :find_features,:check_for_access

  def index
   
  end   

  def new
    if @event.telecaller_accessible_columns.present?
      redirect_to edit_admin_event_telecaller_accessible_column_path(:event_id => @event.id, :id => @event.telecaller_accessible_columns.first.id)
    else
      @telecaller_accessible_column = @event.telecaller_accessible_columns.build
      #@invitee_structures = @event.invitee_structures.first.attributes.except('id','event_id','created_at','updated_at','uniq_identifier','email_field','parent_id')
      @invitee_structures = @event.invitee_structures.first.attributes.except('id','event_id','created_at','updated_at','uniq_identifier','email_field','parent_id','mandate_attr2','mandate_attr3','mandate_attr4','mandate_attr5','mandate_attr6','mandate_attr7','mandate_attr8','mandate_attr9','mandate_attr10','mandate_attr11','mandate_attr12','mandate_attr13','mandate_attr14','mandate_attr15','mandate_attr16','mandate_attr17','mandate_attr18','mandate_attr19','mandate_attr20','mandate_attr21','mandate_attr22','mandate_attr23','mandate_attr24','mandate_attr25','mandate_attr26','mandate_attr27','mandate_attr28','mandate_attr29','mandate_attr30','multi_lng_parent_id','language_updated','expiry_date')
    end
  end


  def create
    @telecaller_accessible_column = @event.telecaller_accessible_columns.build(telecaller_accessible_column_params)
    if @telecaller_accessible_column.save
      unsub_invitee_datum_status
      redirect_to admin_event_telecallers_path(:event_id => @event.id) 
    else
      #@invitee_structures = @event.invitee_structures.first.attributes.except('id','event_id','created_at','updated_at','uniq_identifier','email_field','parent_id')
      @invitee_structures = @event.invitee_structures.first.attributes.except('id','event_id','created_at','updated_at','uniq_identifier','email_field','parent_id','mandate_attr2','mandate_attr3','mandate_attr4','mandate_attr5','mandate_attr6','mandate_attr7','mandate_attr8','mandate_attr9','mandate_attr10','mandate_attr11','mandate_attr12','mandate_attr13','mandate_attr14','mandate_attr15','mandate_attr16','mandate_attr17','mandate_attr18','mandate_attr19','mandate_attr20','mandate_attr21','mandate_attr22','mandate_attr23','mandate_attr24','mandate_attr25','mandate_attr26','mandate_attr27','mandate_attr28','mandate_attr29','mandate_attr30','multi_lng_parent_id','language_updated','expiry_date')
      render :action => 'new'
    end
  end

  def edit
    #@invitee_structures = @event.invitee_structures.first.attributes.except('id','event_id','created_at','updated_at','uniq_identifier','email_field','parent_id')
    @invitee_structures = @event.invitee_structures.first.attributes.except('id','event_id','created_at','updated_at','uniq_identifier','email_field','parent_id','mandate_attr2','mandate_attr3','mandate_attr4','mandate_attr5','mandate_attr6','mandate_attr7','mandate_attr8','mandate_attr9','mandate_attr10','mandate_attr11','mandate_attr12','mandate_attr13','mandate_attr14','mandate_attr15','mandate_attr16','mandate_attr17','mandate_attr18','mandate_attr19','mandate_attr20','mandate_attr21','mandate_attr22','mandate_attr23','mandate_attr24','mandate_attr25','mandate_attr26','mandate_attr27','mandate_attr28','mandate_attr29','mandate_attr30','multi_lng_parent_id','language_updated','expiry_date')
  end

  def update
    if @telecaller_accessible_column.update_attributes(telecaller_accessible_column_params)
      unsub_invitee_datum_status
      redirect_to admin_event_telecallers_path(:event_id => @event.id)
    else
      #@invitee_structures = @event.invitee_structures.first.attributes.except('id','event_id','created_at','updated_at','uniq_identifier','email_field','parent_id')
      @invitee_structures = @event.invitee_structures.first.attributes.except('id','event_id','created_at','updated_at','uniq_identifier','email_field','parent_id','mandate_attr2','mandate_attr3','mandate_attr4','mandate_attr5','mandate_attr6','mandate_attr7','mandate_attr8','mandate_attr9','mandate_attr10','mandate_attr11','mandate_attr12','mandate_attr13','mandate_attr14','mandate_attr15','mandate_attr16','mandate_attr17','mandate_attr18','mandate_attr19','mandate_attr20''mandate_attr21','mandate_attr22','mandate_attr23','mandate_attr24','mandate_attr25','mandate_attr26','mandate_attr27','mandate_attr28','mandate_attr29','mandate_attr30','multi_lng_parent_id','language_updated','expiry_date')
      render :action => "edit"
    end
  end


  def show

  end

  protected
  def telecaller_accessible_column_params
    if params[:telecaller_accessible_column][:accessible_attribute].present?
      params.require(:telecaller_accessible_column).permit!
    else
      {"accessible_attribute"=>{}}
    end
  end

  def unsub_invitee_datum_status
    unsub_emails = Unsubscribe.unsub_emails(@event)
    invitee_datas = @event.invitee_datums.where(attr1: unsub_emails) rescue nil
    if invitee_datas.present? and @telecaller_accessible_column.allow_unsubscribers?
      invitee_datas.where(status: 'unsubscribed_user').update_all(status: nil) rescue nil
    else
      invitee_datas.where(status: nil).update_all(status: 'unsubscribed_user') rescue nil
    end
  end

end
