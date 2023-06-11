class Admin::UnsubscribesController < ApplicationController
  layout 'admin'
  skip_before_filter :authenticate_user, :load_filter, :only => [:index, :show]

  def index
    if params[:event_id].present?
      @event = Event.find(params[:event_id])
      @unsubscribes = Unsubscribe.where(:event_id => @event.id,:unsubscribe => "true")
    end
  end
  def new
    @import = Import.new if params[:import].present?
  end

  def show
    render :layout => false
  end

  def update
    unsub = Unsubscribe.find_by_id(params[:id])
    if unsub.present?
      unsub.update_column(:unsubscribe, 'false')
    end
    redirect_to action: :index
  end
end
