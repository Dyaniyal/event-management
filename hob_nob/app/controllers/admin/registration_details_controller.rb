class Admin::RegistrationDetailsController < ApplicationController
  layout 'admin'
  skip_before_filter :authenticate_user!
  skip_before_filter :load_filter
  before_filter :authorize_event_role

  def index
  	# @total_invitees =  @event.invitees.count
  	@total_invitees = EdmMailSent.where(:event_id => @event.id, :invitee_campaign => true).count
    #campaigns = @event.campaigns.pluck(:id)
    edms = Edm.where("campaign_id =? AND event_id =?",0,@event.id).pluck(:id) #if campaigns.present?
    @total_edm_sent = edms.present? ? EdmMailSent.where("edm_id IN (?) and event_id = ?",edms,@event.id).count : 0
    @total_edm_open = EdmMailSent.where(:event_id => @event.id,:open => "yes").where('edm_id IN (?)',edms).count
    
    @target_registrations = @event.registration_settings.present? ? @event.registration_settings.first.target_registration : 0 
  	@pending_registrations = @event.user_registrations.where(:status=>"pending").count
  	@on_hold_registrations = @event.user_registrations.where(:status=>"on_hold").count
  	@drop_out_registrations = @event.user_registrations.where(:status=>"drop_out").count
  	@confirmed_registrations = @event.user_registrations.where(:status=>"confirmed").count
  	@approved_registrations = @event.user_registrations.where(:status=>"approved").count
    @rejected_registrations = @event.user_registrations.where(:status=>"rejected").count
    @total_registrations = @event.user_registrations.count
  end

  def show
  	@registration = @event.registrations.first if @event.registrations.present?
  	if params[:type].present? and params[:type] =="total"
      @registrations = @event.user_registrations.paginate(page: params[:page], per_page: 10)
    elsif params[:type].present?
  		@registrations = @event.user_registrations.where(:status=>"#{params[:type]}").paginate(page: params[:page], per_page: 10) 
    elsif params[:type].blank?
      @registrations = @event.user_registrations.paginate(page: params[:page], per_page: 10)
  	end	
  end	
end
