class Admin::HighlightImagesController < ApplicationController
	layout 'admin'

  before_filter :authenticate_user, :authorize_event_role, :find_features
  
	def index
    @highlight_image = @event.highlight_images
	end

	def new
    @highlight_image = @event.highlight_images.build
	end

  def create
    #@highlight_image = @event.highlight_images.build(highlight_image_params)
    @highlight_image = @event.highlight_images.build(:highlight_image => params[:highlight_image][:highlight_image].first)
    if @highlight_image.save
      respond_to do |format|
        format.html {  
          render :json => { :files => [@highlight_image.to_jq_upload], 
          :content_type => 'text/html',
          :layout => false
         }
        }
        format.json {  
          render :json => {:files => [@highlight_image.to_jq_upload] }
        }
      end
    else 
      render :json => [{:error => "custom_failure"}], :status => 304
    end
  end

  def destroy
    @highlight_image.destroy
    redirect_to edit_admin_event_event_highlight_path(:event_id => @event.id,:id => @event.id) 
    #admin_event_highlight_images_path(:event_id => @event.id) 
  end

	protected

  def highlight_image_params
    params.require(:highlight_image).permit!
  end
end
