class Admin::EventFeaturesController < ApplicationController
  layout 'admin'

  load_and_authorize_resource
  before_filter :authenticate_user, :authorize_event_role, :find_features
  
  def index
    redirect_to admin_event_menus_path(:event_id => @event.id)
  end

  def new
    if params[:feature] == "my_calender"
      @event_feature = @event.event_features.new
      @event_feature.menu_icon_visibility = nil
    else
      @default_features = @event.set_features_default_list
      @static_features = @event.set_features_static_list
      @present_feature = @event.set_features rescue []
    end  
  end

  def create
    if params[:calender].present?
      calender_setting
      # elsif params[:faq_setting].present?
      #   faq_setting
    elsif params[:image_setting].present?
      image_setting
    else
      if params[:multiple_create].present?
        @event.add_features(params)
        redirect_to admin_event_mobile_application_path(:event_id => @event.id, :id => @event.mobile_application_id)
      else
        if @event.update_attributes(event_params)
          redirect_to admin_event_mobile_application_path(:event_id => @event.id, :id => @event.mobile_application_id)
        else
          render :action => 'index'
        end
      end
    end    
  end

  def update
    # if params[:status].present?
    #   @event_feature.set_status(params[:status])
    #   redirect_to admin_event_menus_path(:event_id => @event.id)
    # end
  end

  def destroy
    # if @event_feature.destroy
    #   redirect_to admin_event_event_features_path(:event_id => @event.id)
    # end
  end

	protected
  def event_params
    params.require(:event).permit! if params[:event].present?
  end
  
  def calender_setting
    if params["event_feature"]["menu_icon_visibility"].blank?
      @feature_error = "This field is required."
      render :action => "new"
    else
      @feature_error = nil
      feature = @event.event_features.where(name: "my_calendar").first rescue []
      params[:event_feature][:menu_icon_visibility] = params[:event_feature][:menu_icon_visibility].downcase rescue ""
      if feature.present?
        feature.update(event_feature_params)
        redirect_to admin_event_agendas_path(:event_id => @event.id)
      else
        @event_feature = @event.event_features.new(event_feature_params)
        if @event_feature.save
          redirect_to admin_event_agendas_path(:event_id => @event.id)
        else
          @event_feature.menu_icon_visibility = nil
          @feature_error = "This field is required."
          render :action => "new"
        end
      end
    end 
  end

  def image_setting
    if params["event_feature"]["image_setting"].blank?
      @feature_error = "This field is required."
      render :action => "new"
    else
      @feature_error = nil
      feature = @event.event_features.where(name: "galleries").first rescue []
      if feature.present?
        feature.update(event_feature_params)
        redirect_url = feature.image_setting == 'Yes' ? admin_event_folders_path(:event_id => @event.id) : admin_event_images_path(:event_id => @event.id)
        redirect_to redirect_url
      else
        @event_feature = @event.event_features.new(event_feature_params)
        if @event_feature.save
          redirect_url = @event_feature.image_setting == 'Yes' ? admin_event_folders_path(:event_id => @event.id) : admin_event_images_path(:event_id => @event.id)
          redirect_to redirect_url
        else
          @event_feature.image_setting = nil
          @feature_error = "This field is required."
          render :action => "new"
        end
      end
    end  
  end

  # def faq_setting
  #   if params["event_feature"]["faq_setting"].blank?
  #     @feature_error = "This field is required."
  #     render :action => "new"
  #   else
  #     @feature_error = nil
  #     feature = @event.event_features.where(name: "faqs").first rescue []
  #     if feature.present?
  #       feature.update(event_feature_params)
  #       redirect_to admin_event_mobile_application_path(:event_id => @event.id, :id => @event.mobile_application.id, :type => "show_content")
  #     else
  #       @event_feature = @event.event_features.new(event_feature_params)
  #       if @event_feature.save
  #         redirect_to admin_event_mobile_application_path(:event_id => @event.id, :id => @event.mobile_application.id, :type => "show_content")
  #       else
  #         @event_feature.faq_setting = nil
  #         @feature_error = "This field is required."
  #         render :action => "new"
  #       end
  #     end
  #   end
  # end

  def event_feature_params
    if params[:event_feature].present?
      params.require(:event_feature).permit! 
    end  
  end
end
