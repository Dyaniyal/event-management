class Admin::AboutsController < ApplicationController

	layout 'admin'
	before_filter :authenticate_user, :find_event

	def index
	end

	def new
		if @event.about.present?
			redirect_to edit_admin_event_about_path(:event_id => @event.id, :id => @event.id)
		end
	end

	def edit
	end

  def create
		if params[:event].present? #and params[:event][:about].present?
			@event.about = params[:event][:about]
			if @event.about_was.blank? and @event.parent_id.blank?
				multi_lng_events = Event.where(parent_id: @event.id)
				multi_lng_events.update_all(about: @event.about) if multi_lng_events.present?
			end
			if params[:event][:about_language_updated].present?
				@event.about_language_updated = params[:event][:about_language_updated]
			end
			@event.save
			if params[:from] == "microsites"
	      redirect_to admin_event_microsite_path(:event_id => @event.id, :id => @event.microsite.id, :type => "show_content")
      else
				redirect_to admin_event_mobile_application_path(:event_id => @event.id, :id => @event.mobile_application.id, :type => "show_content")
			end
		else
			render :action => "new"
		end
  end

	def destroy
	end

	def show
	end

	protected

	def find_event
		@event = Event.find_by_id(params[:event_id])
	end

	def events_params
    params.require(:event).permit!.except(:features)
  end
end
