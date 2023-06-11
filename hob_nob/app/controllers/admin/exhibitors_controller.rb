class Admin::ExhibitorsController < ApplicationController
	layout 'admin'

  load_and_authorize_resource
  before_filter :authenticate_user, :authorize_event_role, :find_features

	def index
    @exhibitors = Exhibitor.search(params, @exhibitors) if params[:search].present?
    #@exhibitors = @exhibitors.paginate(page: params[:page], per_page: 10)
	end

	def new
		@exhibitor = @event.exhibitors.build
	end

	def create
		@exhibitor = @event.exhibitors.build(exhibitor_params)
    if @exhibitor.save
      redirect_to admin_event_exhibitors_path(:event_id => @exhibitor.event_id)
    else
      render :action => 'new'
    end
	end

	def edit
	end

	def update
		if @exhibitor.update_attributes(exhibitor_params)
      redirect_to admin_event_exhibitors_path(:event_id => @exhibitor.event_id)
    else
      render :action => "edit"
    end
	end

	def show
  end

  def destroy
    if @exhibitor.destroy
      redirect_to admin_event_exhibitors_path(:event_id => @exhibitor.event_id)
    end
  end

	protected
	
  def exhibitor_params
    params.require(:exhibitor).permit!
  end
end
