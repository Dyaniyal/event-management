class Admin::TelecallerSearchsController < ApplicationController
	layout 'admin'
	before_filter :authenticate_user
	before_filter :find_event

	def index 
		if current_user.has_role? :telecaller 
			@telecaller = User.unscoped.find(current_user.id)
	    @telecaller_accessible_columns = @event.telecaller_accessible_columns.first.accessible_attribute if @event.telecaller_accessible_columns.present?
	    telecaller_group = @telecaller.telecaller_groups.where(:event_id=>@event.id).first
	    @grouping = Grouping.where("id IN (?)",telecaller_group.assign_grouping) if telecaller_group.present?
	    @groupings = Grouping.with_role(@telecaller.roles.pluck(:name), @telecaller)
	    @invitee_structure = @event.invitee_structures.first if @event.invitee_structures.present?
	    @invitee_data = InviteeDatum.unscoped.where("invitee_structure_id = ?",@invitee_structure)#
	    data = Grouping.get_multiple_group_data_count(@invitee_data, @grouping) if @grouping.present? and @invitee_data.present?
	    # data = data.where(:status => nil)
	    @callback_data = User.get_callback_invitees(data, @event).first
	    @data = data.where("attr1 LIKE ? or attr2 LIKE ? or attr3 LIKE ? or attr4 LIKE ? or attr5 LIKE ? or attr6 LIKE ? or attr7 LIKE? or attr8 LIKE ? or attr9 LIKE ? or attr10 LIKE ? or attr11 LIKE ? or attr12 LIKE ? or attr13 LIKE ? or attr14 LIKE ? or attr15 LIKE ? or attr16 LIKE ? or attr17 LIKE ? or attr18 LIKE ? or attr19 LIKE ? or attr20 LIKE ?", "%#{params[:search_keyword]}%", "%#{params[:search_keyword]}%", "%#{params[:search_keyword]}%", "%#{params[:search_keyword]}%", "%#{params[:search_keyword]}%", "%#{params[:search_keyword]}%", "%#{params[:search_keyword]}%", "%#{params[:search_keyword]}%", "%#{params[:search_keyword]}%", "%#{params[:search_keyword]}%", "%#{params[:search_keyword]}%", "%#{params[:search_keyword]}%", "%#{params[:search_keyword]}%", "%#{params[:search_keyword]}%", "%#{params[:search_keyword]}%", "%#{params[:search_keyword]}%", "%#{params[:search_keyword]}%", "%#{params[:search_keyword]}%", "%#{params[:search_keyword]}%", "%#{params[:search_keyword]}%" ) if data.present?
	    session[:tele_previous_url] = request.referrer unless request.referrer.include? "telecaller_searchs"
	    if @data.present? and @data.count == 1 
        redirect_to admin_event_telecaller_path(:event_id => params[:event_id], :id => @telecaller.id, :callback_id => @data.first.id)
		  	return true
		  end
		end
  end
  protected

  def telecaller_searchs_params
    params.require(:user).permit!
  end

  def find_event
    @event = Event.find(params[:event_id])
  end

  def find_default_group
    if @event.invitee_structures.last.present?
      @invitee_structure = @event.invitee_structures.last
      @invitee_datum = (InviteeDatum.where(:invitee_structure_id => @invitee_structure.id))
    end
  end
end
