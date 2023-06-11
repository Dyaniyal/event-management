class Admin::AwardsController < ApplicationController
  layout 'admin'
  load_and_authorize_resource
  before_filter :authenticate_user, :authorize_event_role, :find_features
  
	def index
    @awards = Award.search(params, @awards) if params[:search].present?
    @awards = @awards
  end
  
	def new
		@award = @event.awards.build
	end

	def create
		@award = @event.awards.build(award_params)
    if @award.save
      if params[:type].present?
        redirect_to admin_event_mobile_application_path(:event_id => @event.id,:id => @event.mobile_application_id,:type => "show_content")
      else
        redirect_to admin_event_awards_path(:event_id => @award.event_id)
      end
    else
      render :action => 'new'
    end
	end

	def edit
	end

	def update
  	if @award.update_attributes(award_params)
      redirect_to admin_event_awards_path(:event_id => @award.event_id)
    else
      render :action => "edit"
    end
	end

	def show
  end

  def destroy
    if @award.destroy
      redirect_to admin_event_awards_path(:event_id => @award.event_id)
    end
  end

	protected
  def find_features
    @event = Event.find(params[:event_id])
    @awards = @event.awards
    @award = @awards.find_by_id(params[:id]) rescue nil if params[:id].present? and @awards.present?
  end

  def award_params
    params.require(:award).permit!
  end
end
