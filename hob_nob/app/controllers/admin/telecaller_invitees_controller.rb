class Admin::TelecallerInviteesController < ApplicationController
	layout 'admin'

  #skip_before_filter :authenticate_user, :find_event, :only => [:show]
  before_filter :authenticate_user#, :except => [:show]
  #before_filter :telecaller_is_login, :except => [:show]
  before_filter :find_event

  def index
  end

  def new
    @telecaller = User.unscoped.find(current_user.id)
    @telecaller_accessible_columns = @event.telecaller_accessible_columns.first.accessible_attribute if @event.telecaller_accessible_columns.present?
    telecaller_group = @telecaller.telecaller_groups.where(:event_id=>@event.id).first
    @grouping = Grouping.where("id IN (?)",telecaller_group.assign_grouping)
    @groupings = Grouping.with_role(@telecaller.roles.pluck(:name), @telecaller)
    @invitee_structure = @event.invitee_structures.first if @event.invitee_structures.present?
    @invitee_data = InviteeDatum.unscoped.where("invitee_structure_id = ?",@invitee_structure)
    data = Grouping.get_multiple_group_data_count(@invitee_data, @grouping) if @grouping.present? and @invitee_data.present?
    @data = data.find_by_id(session[:current_invitee_datum_id]) if session[:current_invitee_datum_id].present? and callback.blank? rescue nil
    session[:current_invitee_datum_id] = @data.id rescue nil
    @invitee_structure = @data.invitee_structure if @data.present?
    @invitee_data = @invitee_structure.invitee_datum.new
  end

  def create
    @telecaller = User.unscoped.find(current_user.id)
    @telecaller_accessible_columns = @event.telecaller_accessible_columns.first.accessible_attribute if @event.telecaller_accessible_columns.present?
    @invitee_structure = @event.invitee_structures.first
    # @invitee_data = @invitee_structure.invitee_datum.new(invitee_datum_params)
    identifier_key = @invitee_structure.uniq_identifier
    @invitee_data = @invitee_structure.invitee_datum.find_or_initialize_by(@invitee_structure.uniq_identifier => invitee_datum_params[identifier_key.gsub(' ', '_')])
    @invitee_data.attributes = invitee_datum_params
    @invitee_data.errors.add(:attr1, "Email Already Exists") unless @invitee_data.new_record?
    if @invitee_data.new_record? and @invitee_data.save
      redirect_to admin_event_telecaller_path(:event_id => @event.id,:id => current_user.id, callback_id: session["invitee_datum_id"])
    else
      render :action => "new"
    end
  end

  protected

  def invitee_datum_params
    params.require(:invitee_datum).permit!
  end

  def find_event
    @event = Event.find(params[:event_id])
  end

  # def telecaller_is_login
  #   if current_user.has_role? :telecaller and params[:action] != "show"
  #     redirect_to destroy_user_session_path
  #   end
  # end

  def find_default_group
    if @event.invitee_structures.last.present?
      @invitee_structure = @event.invitee_structures.last
      @invitee_datum = (InviteeDatum.where(:invitee_structure_id => @invitee_structure.id))
    end
  end
end
