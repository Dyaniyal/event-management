class Admin::SponsorsController < ApplicationController
  layout 'admin'

  load_and_authorize_resource
  before_filter :authenticate_user, :authorize_event_role, :find_features

	def index
    @sponsors = Sponsor.search(params, @sponsors) if params[:search].present?
    respond_to do |format|
      format.html  
      format.xls do
        only_columns = [:name, :sponsor_type]
        method_allowed = [:rating]
        send_data @sponsors.to_xls(:only => only_columns, :methods => method_allowed)
      end
    end
	end

	def new
		@sponsor = @event.sponsors.build
    @default_sponsor_type = Sponsor.where(:event_id => @event.id).pluck(:sponsor_type).uniq
    # @sponsor.images.build
	end

	def create
		@sponsor = @event.sponsors.build(sponsor_params)
    if @sponsor.save
      if params[:from] == "microsites"
        redirect_to admin_event_microsite_path(:event_id => @event.id, :id => @event.microsite.id, :type => "show_content")
      else
        redirect_to admin_event_sponsors_path(:event_id => @sponsor.event_id)
      end
    else
        # @sponsor.images.build if @sponsor.images.count == 0
      @default_sponsor_type = Sponsor.where(:event_id => @event.id).pluck(:sponsor_type).uniq
      render :action => 'new'
    end
	end

	def edit
    # @sponsor.images.build if @sponsor.images.count == 0
    @default_sponsor_type = Sponsor.where(:event_id => @event.id).pluck(:sponsor_type).uniq
	end

	def update
		if @sponsor.update_attributes(sponsor_params)
      if params[:from] == "microsites"
        redirect_to admin_event_sponsors_path(:event_id => @sponsor.event_id, :from => "microsites")
      else
        redirect_to admin_event_sponsors_path(:event_id => @sponsor.event_id)
      end
    else
      # @sponsor.images.build if @sponsor.images.count == 0
      @default_sponsor_type = Sponsor.where(:event_id => @event.id).pluck(:sponsor_type).uniq
      render :action => "edit"
    end
	end

	def show
  end

  def destroy
    if @sponsor.destroy
      if params[:from] == "microsites"
        redirect_to admin_event_sponsors_path(:event_id => @sponsor.event_id, :from => "microsites")
      else
        redirect_to admin_event_sponsors_path(:event_id => @sponsor.event_id)
      end
    end
  end

	protected
  
  def sponsor_params
    params.require(:sponsor).permit!
  end
end
