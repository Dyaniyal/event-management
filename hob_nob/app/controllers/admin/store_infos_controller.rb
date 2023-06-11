class Admin::StoreInfosController < ApplicationController
  layout 'admin'

  load_and_authorize_resource# :except => [:create]
  before_filter :authenticate_user
  before_filter :authorize_event_role, :find_store_info


  def index
    redirect_to admin_event_mobile_application_path(:event_id => params[:event_id], :id => params[:mobile_application_id]) if params[:mobile_application_id].present? and params[:event_id].present?
  end

  def new
    #if @event.avg_review.to_i == 100
      @event.publish! if params[:event] == 'publish' and @event.status == 'approved'
      @event.unpublish! if params[:event] == 'unpublish' and @event.status == 'published'
      if @store_info.present? and @store_info.id.present?
      #  redirect_to admin_event_mobile_application_path(:event_id => @event.id, :id => @mobile_application.id)
        if params[:event].present? and params[:event] == 'unpublish'
          redirect_to admin_event_mobile_application_path(:event_id => @event.id, :id => @mobile_application.id)
        else
          redirect_to edit_admin_event_mobile_application_store_info_path(:event_id => @event.id, :mobile_application_id => @mobile_application.id, :id => @store_info.id)
        end
      else
        if params[:event].present? and params[:event] == 'unpublish'
          redirect_to admin_event_mobile_application_path(:event_id => @event.id, :id => @mobile_application.id)
        end
        @store_info = StoreInfo.new(:mobile_application_id => @mobile_application.id)
      end
    #else
    #  redirect_to admin_event_mobile_application_path(:event_id => @event.id, :id => @mobile_application.id)
    #end
    # 16.times do |i|
    #   @phone_store_screenshot = @store_info.store_screenshots.build
    # end
    # 30.times do |i|
    #   @ios_store_screenshot = @store_info.store_screenshots.build
    # end
  end

  def create
    if @event.present? and @event.mobile_application.present?
      @store_info = StoreInfo.new(store_info_params)
      if @store_info.save
        UserMailer.send_event_mail_to_licensee(@store_info).deliver_now
        redirect_to admin_event_mobile_application_path(:event_id => @event.id, :id => @mobile_application.id)
      else
        render :action => 'new'
      end
    else
    end    
  end

  def edit
    if true#@event.avg_review.to_i < 100
      redirect_to admin_event_mobile_application_path(:event_id => @event.id, :id => @mobile_application.id)
    end
  end

  def update
    if @store_info.update_attributes(store_info_params)
      redirect_to admin_event_mobile_application_path(:event_id => @event.id, :id => @mobile_application.id)
    else
      render :action => "edit"
    end
  end

  def show
  end

  def destroy
    if @store_info.destroy
      redirect_to admin_event_mobile_application_path(:event_id => @event_id, :id => @mobile_application.id)
    end
  end


protected
  def redirect_to_404
    redirect_to '/404.html'
  end

  def find_store_info
    if @event.mobile_application.present?
      @mobile_application = @event.mobile_application
      @store_info = @mobile_application.store_info
      @store_info = StoreInfo.new if params[:action] == 'new' or params[:action] == 'create' and @store_info.blank?
      if @store_info.blank? and params[:id].present?
        redirect_to admin_event_mobile_application_path(:event_id => @event.id, :id => @mobile_application.id)
      else
        @store_screenshots = @store_info.store_screenshots if @store_info.present?
      end
    else
      redirect_to admin_dashboards_path
    end
  end
  
  def store_info_params
    params.require(:store_info).permit!#("mobile_application_id", "is_android_app", "is_ios_app", "android_title", "android_short_desc", "android_full_desc", "android_app_type", "android_category", "android_content_rating", "android_website", "android_email", "android_phone", "android_policy_url", "android_country_list", "android_contains_ads", "android_content_guideline", "android_us_export_laws", "android_app_icon_file_name", "android_app_icon_content_type", "android_app_icon_file_size", "android_app_icon_updated_at", "ios_title", "ios_language", "ios_bundle_id", "ios_sku", "ios_keyword", "ios_support_url", "ios_copyright", "ios_contact_first_name", "ios_contact_last_name", "ios_contact_email", "ios_contact_phone", "ios_demo_email", "ios_password", "ios_notes", "ios_app_icon_file_name", "ios_app_icon_content_type", "ios_app_icon_file_size", "ios_app_icon_updated_at", "created_at", "updated_at", 'mobile_application_id', 'event_id')
  end
end
