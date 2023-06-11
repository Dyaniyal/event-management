class Admin::ActivityFeedsController < ApplicationController
  layout 'admin'
  def index
    @event = Event.find(params[:event_id])
    @activity_feed_feature = @event.event_features.not_hidden_icon.pluck(:name).include? "activity_feeds"
  end

  def new
    @event = Event.find(params[:event_id])
    @activity_feed_feature = @event.event_features.not_hidden_icon.pluck(:name).include? "activity_feeds"
  end
end
