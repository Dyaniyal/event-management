class Admin::TelecallersController < ApplicationController
  layout 'admin'

  before_filter :authenticate_user#, :except => [:show]
  before_filter :find_event
  def index
    @telecallers = User.joins(:roles).where('roles.resource_type = ? and resource_id = ? and roles.name = ?', "Event", @event.id, "telecaller").uniq.paginate(page: params[:page], per_page: 10)
    if params[:change_status].present? and params[:change_status] =="true"
      @telecaller = User.find(params[:id])
      @telecaller.update_column('telecaller_status',params[:status])
      redirect_to :back
    end  
  end

  def new
    @telecaller = User.new
    @telecaller_group = TelecallerGroup.new
  end

  def create
    @telecaller = User.find_or_initialize_by(:email => params[:user][:email])
    if @telecaller.new_record?
      @telecaller = User.new(telecaller_params)
      @grouping = Grouping.where(:id => params[:user][:telecaller_groups_attributes]["0"][:assign_grouping])
    else
      @grouping = Grouping.where(:id => params[:user][:telecaller_groups_attributes]["0"][:assign_grouping])
    end
    @telecaller.status = "active"  
    if @telecaller.save
      @telecaller.add_role_to_telecaller(@telecaller,@event)
      @telecaller.add_role :telecaller,@grouping.first
      return redirect_to admin_event_users_path(:event_id => @event.id,:role=>"all") if params[:get_role].present? 
      return redirect_to admin_event_users_path(:event_id => @event.id) if (!params[:get_role].present? and !params[:telecaller_index].present?) or params[:from_users].present?
      redirect_to admin_event_telecallers_path(:event_id => @event.id) if params[:telecaller_index].present?
    else
      render :action => 'new'
    end
  end

  def edit
    @telecaller = User.unscoped.find(params[:id])
    @telecaller_group = TelecallerGroup.where(:event_id=>@event.id,:user_id=>@telecaller.id)
    if @telecaller_group.present?
    @telecaller_group = @telecaller_group.first
    else  
      @telecaller_group = TelecallerGroup.new
    end
  end

  def update
    @telecaller = User.unscoped.find(params[:id])
    @grouping = Grouping.where(:id => params[:user][:telecaller_groups_attributes]["0"][:assign_grouping])
    if @telecaller.update_attributes(telecaller_params)
      @telecaller.add_role_to_telecaller(@telecaller,@event)
      @telecaller.add_role :telecaller,@grouping.first
      return redirect_to admin_event_users_path(:event_id => @event.id,:role=>"all") if params[:get_role].present? 
      return redirect_to admin_event_users_path(:event_id => @event.id) if (!params[:get_role].present? and !params[:telecaller_index].present?) or params[:from_users].present?
      redirect_to admin_event_telecallers_path(:event_id => @event.id) if params[:telecaller_index].present?
    else
      render :action => "edit"
    end
  end

  def show
    @telecaller = User.unscoped.find(params[:id])
    @telecaller_accessible_columns = @event.telecaller_accessible_columns.first.accessible_attribute if @event.telecaller_accessible_columns.present?
    telecaller_group = @telecaller.telecaller_groups.where(:event_id=>@event.id).first
    @grouping = Grouping.where("id IN (?)",telecaller_group.assign_grouping) if telecaller_group.present?
    @groupings = Grouping.with_role(@telecaller.roles.pluck(:name), @telecaller)
    @invitee_structure = @event.invitee_structures.first if @event.invitee_structures.present?
    @invitee_data = InviteeDatum.unscoped.where("invitee_structure_id = ?",@invitee_structure).exclude_unsubcribes(@event)
    @consent_questions = @event.consent_questions.first(10)   
    data = Grouping.get_multiple_group_data_count(@invitee_data, @grouping) if @grouping.present? and @invitee_data.present?
    if params[:callback_id].present?
      @data = data.find(params[:callback_id]) rescue nil
    else
      @data = data.where(:status => nil).order("RAND()").last rescue nil
    end
    callback = User.get_callback_invitees(data, @event, current_user.id)
    if callback.present?
      @data = data.find(params[:callback_id]) rescue '' if params[:callback_id].present?
      @callback_data = @data.present? ? callback.where("id != ?",@data.id).first : callback.first
      @need_to_call = "true"
    end
    @invitee_structure = @data.invitee_structure if @data.present? and @data.invitee_structure.present?
  end
  
  # def destroy
  #   @telecaller = User.unscoped.find(params[:id])
  #   if @telecaller.destroy
  #     redirect_to admin_event_telecallers_path(:event_id => @event.id)
  #   end
  # end

  # TODO - will be enabled after Approval
  def attended_records
    return go_back unless current_user.has_role? :response_manager
    if params[:invitee_datum_ids].present?
      inv_datums = InviteeDatum.where(id: params[:invitee_datum_ids])
      inv_datums.update_all(status: nil, reported_status: nil)
      redirect_to :back
    end
    @closed_data = @event.invitee_datums.where.not(:status => nil).paginate(page: params[:page], per_page: 10)
    @closed_data = @closed_data.where(params['filter'].permit!) if params['filter'].present? && !params['filter'].has_value?('All')
  end

  protected

  def telecaller_params
    params.require(:user).permit!
  end

  def find_event
    @event = Event.find(params[:event_id])
  end

  def telecaller_is_login
    if current_user.has_role? :telecaller and params[:action] != "show"
      redirect_to destroy_user_session_path
    end
  end

  def find_default_group
    if @event.invitee_structures.last.present?
      @invitee_structure = @event.invitee_structures.last
      @invitee_datum = (InviteeDatum.where(:invitee_structure_id => @invitee_structure.id))
    end
  end

end
