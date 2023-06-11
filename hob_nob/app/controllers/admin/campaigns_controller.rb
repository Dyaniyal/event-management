class Admin::CampaignsController < ApplicationController
  layout 'admin'
  before_filter :authenticate_user, :authorize_event_role, :find_features
  before_filter :check_for_access
  
  def index
    @campaigns = @event.campaigns.where('id != ? ', 0) 
    @campaigns = @campaigns.paginate(:page => params[:page], :per_page => 10)
  end

  def new
    @campaign = @event.campaigns.build
  end

  def create
    @campaign = @event.campaigns.build(campaign_params)
    @campaign.event_id = @event.id if @event.present?
    @campaign.events << @event
    if @campaign.save
      redirect_to admin_event_campaigns_path(:event_id => @campaign.event_id)
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @campaign.update_attributes(campaign_params)
      redirect_to admin_event_campaigns_path(:event_id => @campaign.event_id)
    else
      render :action => "edit"
    end
  end

  def show
  end

  def destroy
    if @campaign.destroy
      redirect_to admin_event_campaigns_path(:event_id => @campaign.event_id)
    end
  end

  protected
    def campaign_params
      params.require(:campaign).permit!
    end
end
