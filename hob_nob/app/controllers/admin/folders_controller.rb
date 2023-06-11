class Admin::FoldersController < ApplicationController
		layout 'admin'
  before_filter :authenticate_user
  before_action :find_event
  
	def index
    @folders = Folder.where(event_id: params[:event_id]).includes(:images)
	end

	def new
		@folder = @event.folders.build
	end

	def create
    @folder = @event.folders.build(folder_params)
    if @folder.save
      if params[:from] == "microsites"
        redirect_to admin_event_folders_path(:event_id => @folder.event_id, :from => "microsites")
      else
        redirect_to admin_event_folders_path(:event_id => @folder.event_id)
      end
    else
      render :action => 'new'
    end
	end

	def edit
		@folder = Folder.find(params[:id])
	end

  def update
    @folder = Folder.find(params[:id])
    if @folder.update_attributes(folder_params)
      if params[:from] == "microsites"
        redirect_to admin_event_folders_path(:event_id => @folder.event_id, :from => "microsites")
      else
        redirect_to admin_event_folders_path(:event_id => @folder.event_id)
      end
    else
      render :action => "edit"
    end
	end

  def show
  	@folder = Folder.find(params[:id])
  end

  def destroy
  	@folder = Folder.find(params[:id])
    if @folder.destroy
      if params[:from] == "microsites"
        redirect_to admin_event_folders_path(:event_id => @folder.event_id, :from => "microsites")
      else
        redirect_to admin_event_folders_path(:event_id => @folder.event_id)
      end
    end
  end

	protected

	def find_event
		@event = Event.find(params[:event_id])
	end

  def folder_params
    params.require(:folder).permit(:id, :name, :sequence, :event_id)
  end
end
