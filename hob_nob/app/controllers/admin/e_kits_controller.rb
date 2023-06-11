class Admin::EKitsController < ApplicationController
	layout 'admin'

  load_and_authorize_resource
  before_filter :authenticate_user, :authorize_event_role, :find_features
  before_filter :find_groups, :only => [:new, :create, :edit, :update]

  def index
    if params[:tag].present?
      @tags = @event.e_kits.tagged_with([params[:tag]])
    else 
      @tags = @event.e_kits.tag_counts_on(:tags)
      @tags = EKit.search(params, @tags) if params[:search].present?
      @tags = EKit.search_tag(params, @tags) if params[:search].present?
      @tags = @tags.paginate(page: params[:page], per_page: 10)
      #all_ids = @e_kits.pluck(:id)
      # @tags.each do |tag|
      #   removed_ekits = @event.e_kits.tagged_with(tag.name)
      #   removed_ekits.each do |removed_ekit|
      #     all_ids.delete(removed_ekit.id)
      #   end
      # end
      # @e_kits = EKit.where(:id => all_ids) rescue nil
    end 
  end

	def new
		@e_kit = @event.e_kits.build
	end

	def create
		@e_kit = @event.e_kits.build(e_kit_params)
    if @e_kit.save
      if params[:type].present?
        redirect_to admin_event_mobile_application_path(:event_id => @event.id,:id => @event.mobile_application_id,:type => "show_engagement")
      else
        redirect_to admin_event_e_kits_path(:event_id => @e_kit.event_id)
      end
    else
      render :action => 'new'
    end
	end

	def edit
	end

	def update
	  if @e_kit.update_attributes(e_kit_params)
        redirect_to admin_event_e_kits_path(:event_id => @e_kit.event_id)
    else
      render :action => "edit"
    end
	end

  def show
  end

  def destroy
    if @e_kit.destroy
      redirect_to admin_event_e_kits_path(:event_id => @e_kit.event_id)
    end
  end

  protected
  def find_groups
    @event = Event.find(params[:event_id])
    @groups = @event.invitee_groups
    @default_groups = []#@groups.where(:name => ['No Polls taken', 'No Feedback given', 'No Quiz taken', 'No Q&A Participation', 'No Participation in Conversations', 'No Favorites added'])
    @other_groups = @groups.where('name NOT IN (?)', ['No Polls taken', 'No Feedback given', 'No Quiz taken', 'No Q&A Participation', 'No Participation in Conversations', 'No Favorites added'])
  end
  def e_kit_params
    params.require(:e_kit).permit!
  end
end
