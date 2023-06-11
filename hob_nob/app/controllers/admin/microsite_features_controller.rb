class Admin::MicrositeFeaturesController < ApplicationController
 layout 'admin'
 before_filter :authenticate_user, :authorize_event_role, :find_microsite_features, :find_microsite, :find_event

  def new
    @microsite_feature = @microsite.microsite_features.new
    @default_features = @event.microsite.set_microsite_features_default_list
    @present_feature = @event.microsite.set_microsite_features rescue []
  end

  def create
    # if params[:faq_setting].present?
    #   faq_setting
    if params[:image_setting].present?
      image_setting
    else
      if params[:multiple_create].present?
        @microsite.add_microsite_features(params)
        redirect_to admin_event_microsite_path(:event_id => @event.id, :id => @event.microsite.id)
      else
        render :action => 'index'
      end
    end    
  end

  protected

  def find_microsite
    @microsite = Microsite.find(params[:microsite_id])
  end

  def find_event
    @event = Event.find(params[:event_id])
  end

  def image_setting
    if params["microsite_feature"]["image_setting"].blank?
      @feature_error = "This field is required."
      render :action => "new"
    else
      @feature_error = nil
      feature =  @microsite.microsite_features.where(name: "images").first rescue []
      if feature.present?
        feature.update(microsite_feature_params)
        redirect_url = feature.image_setting == 'Yes' ? admin_event_folders_path(:event_id => @event.id, :from => "microsites") : admin_event_images_path(:event_id => @event.id, :from => "microsites")
        redirect_to redirect_url
      else
        @microsite_feature = @microsite.microsite_features.new(microsite_feature_params)
        if @microsite_feature.save
          redirect_url = @microsite_feature.image_setting == 'Yes' ? admin_event_folders_path(:event_id => @event.id, :from => "microsites") : admin_event_images_path(:event_id => @event.id, :from => "microsites")
          redirect_to redirect_url
        else
          @microsite_feature.image_setting = nil
          @feature_error = "This field is required."
          render :action => "new"
        end
      end
    end
  end

  # def faq_setting
  #   if params["microsite_feature"]["faq_setting"].blank?
  #     @feature_error = "This field is required."
  #     render :action => "new"
  #   else
  #     @feature_error = nil
  #     feature = @microsite.microsite_features.where(name: "faqs").first rescue []
  #     if feature.present?
  #       feature.update(microsite_feature_params)
  #       redirect_to admin_event_microsite_path(:event_id => @event.id,:id => @event.microsite.id, :type => "show_content")
  #     else
  #       @microsite_feature = @microsite.microsite_features.new(microsite_feature_params)
  #       if @microsite_feature.save
  #         redirect_to admin_event_microsite_path(:event_id => @event.id,:id => @event.microsite.id, :type => "show_content")
  #       else
  #         @microsite_feature.faq_setting = nil
  #         @feature_error = "This field is required."
  #         render :action => "new"
  #       end
  #     end
  #   end
  # end
  def microsite_feature_params
    params.require(:microsite_feature).permit!   
  end
end