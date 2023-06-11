class Admin::CampaignDetailsController < ApplicationController
  layout 'admin'
  skip_before_filter :authenticate_user!
  skip_before_filter :load_filter
  before_filter :authorize_event_role

  def index
    if params[:edm_id].present?
      Edm.find(params[:edm_id]).consent_links.each do |consent_link|
        instance_variable_set("@#{consent_link.sub('track', 'consent')}", true)
      end
      @registration_statistic = Edm.find(params[:edm_id]).mail_to.capitalize if Edm.find(params[:edm_id]).campaign_id == 0
      @total_edm_sent = EdmMailSent.where(:edm_id => params[:edm_id]).count
      @total_edm_open = EdmMailSent.where(:edm_id => params[:edm_id],:open => "yes").count
      (1..10).to_a.each { |n| instance_variable_set("@track_links_for_#{n}", TrackLink.get_edm_count(params[:edm_id], "track_link_#{n}")) }
    else
      @registration_edms = Edm.where(:event_id => @event.id,:campaign_id => 0).pluck(:id)
      if @registration_edms.present?
        @total_edm_sent = EdmMailSent.where(:event_id => @event.id).where('edm_id NOT IN (?)',@registration_edms).count
        @total_edm_open = EdmMailSent.where(:event_id => @event.id,:open => "yes").where('edm_id NOT IN (?)',@registration_edms).count
      else
        @total_edm_sent = EdmMailSent.where(:event_id => @event.id).count
        @total_edm_open = EdmMailSent.where(:event_id => @event.id,:open => "yes").count
      end
      (1..10).to_a.each { |n| instance_variable_set("@track_links_for_#{n}", TrackLink.get_count(@event.id, "track_link_#{n}")) }
      respond_to do |format|
        format.html  
        format.xls do
          only_columns = []
          method_allowed = [:Campaign_Name,:eDM_Name,:Number_sent,:Number_opened,:number_of_track_link_1_clicks,:number_of_track_link_2_clicks,:number_of_track_link_3_clicks,:number_of_track_link_4_clicks,:number_of_track_link_5_clicks,:number_of_track_link_6_clicks]
          if @registration_edms.present?
            @total_edm = EdmMailSent.where(:event_id => @event.id).where('edm_id NOT IN (?)',@registration_edms).group(:edm_id)
          else
            @total_edm = EdmMailSent.where(:event_id => @event.id).group(:edm_id)
          end
          send_data @total_edm.to_xls(:only => only_columns, :methods => method_allowed)
        end
      end
    end
  end
  
end