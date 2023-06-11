class Admin::ImagesController < ApplicationController
  layout 'admin'

  before_filter :authenticate_user, :authorize_event_role, :find_features
  
	def index
    @image = @event.images
	end

	def new
    @image = @event.images.build
    @folder = Folder.find(params[:folder_id]) rescue ""
    render "add_new"
	end

  def create
    #@image = @event.images.build
    #@image = @event.images.build(image_params)
    @image = @event.images.build(:image => params[:image][:image].first, :folder_id => params[:image][:folder_id])
    if @image.save
      respond_to do |format|
        format.html {  
          render :json => { :files => [@image.to_jq_upload], 
          :content_type => 'text/html',
          :layout => false
         }
        }
        format.json {  
          render :json => {:files => [@image.to_jq_upload] }
        }
      end
    else 
      render :json => [{:error => "custom_failure"}], :status => 304
    end
  end

  def update
    if params[:from] == "microsites"
      redirect_to admin_event_images_path(:event_id => @event.id, :from => "microsites")
    else    
      redirect_to admin_event_images_path(:event_id => @event.id) 
    end
  end

  def destroy
    @image.destroy
    if params[:folder_id].present?
      redirect_to admin_event_folder_path(:event_id => @event.id, :id =>  params[:folder_id])
    elsif  params[:from] == "microsites"
      redirect_to admin_event_images_path(:event_id => @event.id, :from => "microsites")
    else
      redirect_to admin_event_images_path(:event_id => @event.id) 
    end
  end

	protected

  def image_params
    params.require(:image).permit!
  end

end
