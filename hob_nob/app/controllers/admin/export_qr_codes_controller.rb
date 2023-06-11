class Admin::ExportQrCodesController < ApplicationController

	before_filter :find_event, :change_format

	def index
		if params[:export].present?
      @qr_codes = @event.analytics.select('distinct invitee_id, viewable_url, created_at, event_id').where.not(viewable_url: [nil, ""])
      respond_to do |format|
        format.xls do
          method_allowed = [:timestamp, :invitee_email, :url]
          # only_columns = [:viewable_url]
          send_data @qr_codes.to_xls(:methods => method_allowed)#, :only => only_columns)
        end
      end
    end
	end

	private

	def find_event
    @event = Event.find_by_id(params[:event_id])
  end

  def change_format
    request.format = "xls"
  end

end
