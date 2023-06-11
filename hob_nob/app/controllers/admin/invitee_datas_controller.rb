class Admin::InviteeDatasController < ApplicationController
  layout 'admin'

  #load_and_authorize_resource
  before_filter :authenticate_user, :authorize_event_role, :find_invitee_data
    
  def index
    @invitee_structure = @event.invitee_structures.first
    @invitee_data = @invitee_structure.invitee_datum#InviteeStructure.search(params, @invitee_structures) if params[:search].present?
    @grouping = Grouping.find_by_id(params[:grouping_id]) if params[:grouping_id].present?
    @invitee_data = @grouping.get_search_data_count(@invitee_data) if @grouping.present?
    @invitee_data = @invitee_data.paginate(page: params[:page], per_page: 10)
    respond_to do |format|
      format.html  
      format.xls do
        
      end
    end
  end

  def new
    if @event.invitee_structures.present?
      redirect_to edit_admin_event_invitee_structure_path(:event_id => @event.id, :id => @event.invitee_structures.first.id)
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
    @consent_questions = @event.consent_questions.first(10)
    if params[:invitee_datum][:check_remark_and_status_present] == "true"
      @invitee_data.check_callback_time_and_date(params[:invitee_datum]) if (params[:invitee_datum][:status] == "CALL BACK - NO RESPONSE" or params[:invitee_datum][:status] == "FOLLOW UP" or params[:invitee_datum][:status] == "WARM" or params[:invitee_datum][:status] == "HOT")
      @invitee_data.set_time(params["invitee_datum"]["callback_date"], params["invitee_datum"]["callback_time_hour"], params["invitee_datum"]["callback_time_minute"], params["invitee_datum"]["callback_time_am"]) rescue nil if (params[:invitee_datum][:status] == "CALL BACK - NO RESPONSE" or params[:invitee_datum][:status] == "FOLLOW UP" or params[:invitee_datum][:status] == "WARM" or params[:invitee_datum][:status] == "HOT")
      # if (params[:invitee_datum][:status] == "CALL BACK - NO RESPONSE" or params[:invitee_datum][:status] == "FOLLOW UP")
      #   @invitee_data.call_attempt  = @invitee_data.call_attempt.present? ? @invitee_data.call_attempt+1 : 1 
      # end
      if @invitee_data.update_attributes(invitee_datum_params)
        if (params[:invitee_datum][:status] == "CALL BACK - NO RESPONSE" or params[:invitee_datum][:status] == "FOLLOW UP" or params[:invitee_datum][:status] == "WARM" or params[:invitee_datum][:status] == "HOT")
          attempt  = @invitee_data.call_attempt.present? ? @invitee_data.call_attempt+1 : 1
          @invitee_data.update_column('call_attempt',attempt)
        end        
        count = (@invitee_data.telecaller_update_count.present? ? (@invitee_data.telecaller_update_count.to_i + 1) : "1")
        @invitee_data.update_column('telecaller_update_count',count) if  params[:invitee_datum]["is_updated"] == "true"
        session[:current_invitee_datum_id] = nil

        if params[:invitee_datum][:edm_selected].present?
          edm = Edm.find_by_id(params[:invitee_datum][:edm_selected])
          if edm.present?
            smtp_setting = @event.smtp_setting.present? ? @event.smtp_setting : @event.get_licensee_admin.smtp_setting
            invitee_structure = @invitee_data.invitee_structure
            database_data = invitee_structure.present? ? invitee_structure.invitee_datum : ""
            database_email_field = invitee_structure.email_field? ? invitee_structure.email_field : ""
            edm.bcc, edm.cc = nil, nil
            UserMailer.send(edm.template_type, edm, @invitee_data.attr1, smtp_setting, nil, 
                            database_data.where(id: @invitee_data.id), database_email_field
                          ).deliver_now
          end
        end
        redirect_to admin_event_telecaller_path(:event_id => @event.id,:id => current_user.id)
      else
        @telecaller = User.unscoped.find(current_user.id)
        @grouping = Grouping.find(@telecaller.assign_grouping) 
        @data = @invitee_data
        @telecaller_accessible_columns = @event.telecaller_accessible_columns.first.accessible_attribute if @event.telecaller_accessible_columns.present?
        render 'admin/telecallers/show'
      end
    elsif params["invitee_datum"]["skip_status_update"].present? and params["invitee_datum"]["skip_status_update"] == "true" 
      @invitee_data.update_attributes(invitee_datum_params)
      redirect_to admin_event_invitee_datas_path(:event_id => @event.id)
    else
      if @invitee_structure.update_attributes(invitee_structure_params)
        redirect_to admin_event_invitee_structures_path(:event_id => @invitee_structure.event_id)
      else
        render :action => "edit"
      end
    end
  end

  # def update_details
  #   if params[:invitee_datum][:check_remark_and_status_present] == "true"
  #     @invitee_data.check_callback_time_and_date(params[:invitee_datum]) if (params[:invitee_datum][:status] == "CALL BACK" or params[:invitee_datum][:status] == "FOLLOW UP")
  #     @invitee_data.set_time(params["invitee_datum"]["callback_date"], params["invitee_datum"]["callback_time_hour"], params["invitee_datum"]["callback_time_minute"], params["invitee_datum"]["callback_time_am"]) rescue nil if (params[:invitee_datum][:status] == "CALL BACK" or params[:invitee_datum][:status] == "FOLLOW UP")
  #     if @invitee_data.update_attributes(invitee_datum_params)
  #       session[:current_invitee_datum_id] = nil
  #       redirect_to admin_event_telecaller_path(:event_id => @event.id,:id => current_user.id)
  #     else
  #       @telecaller = User.unscoped.find(current_user.id)
  #       @grouping = Grouping.find(@telecaller.assign_grouping) 
  #       @data = @invitee_data
  #       render 'admin/telecallers/show'
  #     end
  #   end
  # end

  def show
    redirect_to edit_admin_event_invitee_structure_path(:event_id => @event.id, :id => @event.invitee_structures.first.id)
  end

  def destroy
    if params["invitee_data"].present? and params["invitee_data"] == "true"
      @invitee_data.destroy
      redirect_to admin_event_invitee_datas_path(:event_id => @event.id) 
    elsif @invitee_structure.destroy
      redirect_to admin_event_invitee_structures_path(:event_id => @invitee_structure.event_id)
    end
  end

  protected

  def find_invitee_data
    @invitee_structure = @event.invitee_structures.first
    @invitee_datas = @invitee_structure.invitee_datum
    @invitee_data = @invitee_datas.find_by_id(params[:id]) || @invitee_datas.find_by_id(session[:invitee_datum_id])
    if @invitee_data.blank? and (params[:id].present? or session[:invitee_datum_id].present?)
      redirect_to admin_client_event_path(:client_id => @event.client_id, :id => @event.id)
    end
  end

  
  def invitee_structure_params
    params.require(:invitee_structure).permit!
  end

  def invitee_datum_params
    params.require(:invitee_datum).permit!
  end
end
