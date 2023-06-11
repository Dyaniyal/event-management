class Admin::BadgePdfsController < ApplicationController
  
  layout 'admin'
  before_filter :authenticate_user, :find_event
  before_filter :client_fonts, only: [:new, :edit, :create, :update]
  
	def new
	  @badge_pdf = BadgePdf.new
	  @registration = @event.registrations.first 
    @regi_fields = @registration.column_match_for_badge
  end

	def create
		@badge_pdf = BadgePdf.new(badge_pdf_params)
    if @badge_pdf.save
      redirect_to admin_event_onsite_registrations_path(:event_id => @badge_pdf.event_id)
    else
      @registration = @event.registrations.first
      @regi_fields = @registration.column_match_for_badge
      render :action => 'new'
    end
	end

	def edit
  	@badge_pdf = BadgePdf.find(params[:id])
    @registration = @event.registrations.first
    @regi_fields = @registration.column_match_for_badge
  end

  def update
    @badge_pdf = BadgePdf.find(params[:id])
    if params[:remove_image] == "true"
      @badge_pdf.update_attribute(:badge_image, nil) if @badge_pdf.badge_image.present?
      return redirect_to edit_admin_event_badge_pdf_path(:event_id => @badge_pdf.event_id, :id => @badge_pdf.id)
    end
    if params[:remove_scan_bg_image] == "true"
      @badge_pdf.update_attribute(:scan_bg_image, nil) if @badge_pdf.scan_bg_image.present?
      return redirect_to edit_admin_event_badge_pdf_path(:event_id => @badge_pdf.event_id, :id => @badge_pdf.id)
    end
    badge_pdf_params.each {|k, v| badge_pdf_params[k] = "" if v== 'Please select'}
    if @badge_pdf.update_attributes(badge_pdf_params)
      redirect_to admin_event_onsite_registrations_path(:event_id => @badge_pdf.event_id)
    else
      @registration = @event.registrations.first
      @regi_fields = @registration.column_match_for_badge
      render :action => "edit"
    end
  end

	protected
	
  def client_fonts
    @font_styles = Font::DEFAULT_FONTS + @event.client.fonts.map { |font| [font.font_name] * 2 }
  end

  def find_event
		@event = Event.find(params[:event_id])
	end	
	
	def badge_pdf_params
    params.require(:badge_pdf).permit!
  end

end

