class MicrositesController < ApplicationController
  layout 'microsites/microsite_layout'
  skip_before_filter :authenticate_user, :load_filter
  before_filter :find_event#, :only => [:index, :new, :create, :edit]
  
  def show
    @microsite = @event.microsite rescue ''
    if @microsite.present?
      @data = @microsite.get_data(@event, params[:type])
      render :template => params[:type].present? ? "microsites/#{params[:type]}" : "microsites/show"
    else
      redirect_to root_path
    end
  end

  def destroy
  end

  protected
  
  def microsite_params
    params.require(:microsite).permit!
  end

  def find_event
    @event = Event.find_by_seo_name(params[:id])
  end
end

