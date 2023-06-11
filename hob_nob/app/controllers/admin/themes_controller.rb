class Admin::ThemesController < ApplicationController
  layout 'admin'

  load_and_authorize_resource
  before_filter :authenticate_user
  before_filter :find_themes, :except => [:new, :create]

  def index
    @themes = @themes.paginate(:page => params[:page], :per_page => 10)
    @themes = Theme.search(params, @themes) if params[:search].present?
    redirect_to edit_admin_event_theme_path(:event_id => @event.id, :id => @theme.id) if params[:event_id].present? and @theme.present?
  end

  def new
    if params[:event_id].present?
      @event = Event.find(params[:event_id])
      if @event.theme.present? and !(@event.theme.is_preview?) and params[:selected].nil?
        @theme = Event.find(params[:event_id]).theme 
        redirect_to edit_admin_event_theme_path(:event_id => params[:event_id], :id => @theme.id, :step => "event_theme")
      else
        @old_theme = @event.theme || Theme.new
        @theme = Theme.new 
      end
    else
      @old_theme = Theme.find_by_id(params[:id]) || Theme.new
      @theme = Theme.new
    end  
    # @old_theme = Theme.find_by_id(params[:id]) || Theme.new
  end
  
  def create
    if params[:event_id].present?
      @event = Event.find_by_id(params[:event_id])
      @theme = @event.build_theme(theme_params.except(:events_attributes))
      @old_theme = @theme
      if @theme.save
        @event.update_column(:theme_id, @theme.id)
        if themes_event_params.present? and @event.update_attributes(themes_event_params) 
          redirect_to admin_event_mobile_application_path(:event_id => params[:event_id], :id => @event.mobile_application_id)
        elsif themes_event_params.blank?
          redirect_to admin_event_mobile_application_path(:event_id => params[:event_id], :id => @event.mobile_application_id)
        elsif @event.mobile_application.present?
          check_footer_image_error
          check_event_logo_error
          check_event_inside_logo_error
          render :action => "edit"
        end
      else
        check_footer_image_error
        check_event_logo_error
        check_event_inside_logo_error
        @old_event = true
        @logo_file_name = themes_event_params[:logo].original_filename if themes_event_params.present? and themes_event_params[:logo].present? rescue nil
        @inside_file_name = themes_event_params[:inside_logo].original_filename if themes_event_params.present? and themes_event_params[:inside_logo].present? rescue nil
        render :action => 'new'
      end
    else
      @theme = Theme.new(theme_params)
      @theme.admin_theme = true
      @old_theme = @theme
      if @theme.save
        if params[:event_id].present?
          redirect_to admin_event_theme_path(:event_id => params[:event_id], :id => @theme.id)
        else
          redirect_to admin_themes_path
        end
      else
        render :action => 'new'
      end
    end
  end

  def edit
    @old_theme = @theme
  end

  def update
    @old_theme = @theme
    if params[:step] == "event_theme"
      if @theme.update_attributes(theme_params.except(:events_attributes)) 
        @event.update_attributes(:event_type_for_registration => "close") if @event.event_type_for_registration.blank?
        if @event.update_attributes(themes_event_params)
          redirect_to admin_event_mobile_application_path(:event_id => @event, :id => @event.mobile_application_id)
        else
          check_footer_image_error
          check_event_logo_error
          check_event_inside_logo_error
          render :action => "edit"
        end if themes_event_params.present?
      else
        check_footer_image_error
        check_event_logo_error
        check_event_inside_logo_error
        render :action => "edit"
      end
    elsif params[:remove_image] == "true"
      @theme.update_attribute(:event_background_image, nil) if @theme.event_background_image.present?
      redirect_to edit_admin_event_theme_path(:event_id => @event.id, :id => @theme.id, :step => "event_theme")
    elsif params[:remove_footer_image] == "true"
      @event.update_attribute(:footer_image, nil) if @event.footer_image.present?
      redirect_to edit_admin_event_theme_path(:event_id => @event.id, :id => @theme.id, :step => "event_theme")
    else
      if @theme.update_attributes(theme_params.except(:event))
        url = (params[:event_id].present? ? admin_event_mobile_application_path(:event_id => @event, :id => @event.mobile_application_id,:type => "show_content") : admin_themes_path)
        redirect_to url
      else
        render :action => "edit"
      end
    end  
  end

  def show
    if !(current_user.has_role? :super_admin)
      # redirect_to :back
      go_back
    end
  end

  def destroy
    if @theme.destroy
      redirect_to admin_themes_path
    end
  end

  protected

  def find_themes
    @event = Event.find_by_id(params[:event_id]) if params[:event_id].present?
    @themes = Theme.find_themes(@event)
    @theme = @themes.find_by_id(params[:id]) if params[:id].present? and @themes.present?
    @theme = @event.theme if params[:event_id].present? and @event.present?
    # if ['show', 'edit', 'destroy', 'update'].include? params[:action] and @theme.blank?
    #   redirect_to admin_themes_path
    # end
  end

  def themes_event_params
    if params[:theme].present? and params[:theme][:events_attributes].present?
      # if params[:theme][:events_attributes]["0"].present? and params[:theme][:events_attributes]["0"].except("id").present?
      #   params[:theme][:events_attributes].require("0").permit!
      # else
      #   params[:theme][:events_attributes].require("1").permit!
      # end
      if params[:theme][:events_attributes]["0"].present?
        params[:theme][:events_attributes].require("0").permit!
      end
    end
  end

  def theme_params
    params.require(:theme).permit!#(:name, :background_color, :content_font_color, :button_color, :button_content_color, :drawer_menu_back_color, :drawer_menu_font_color, :bar_color, :header_color, :footer_color, :licensee_id)
  end

  def check_event_logo_error
    if params[:theme]["events_attributes"]["0"]["logo"].content_type != "image/png"
      if @event.errors.messages.present?
        if @event.errors.messages[:logo].present? and @event.errors.messages[:logo][0].present?
          @event.errors.messages[:logo][0] = "Selected icon is not in correct format."
        else
          @event.errors.add(:logo, "Selected icon is not in correct format.")
        end
      else  
        @event.errors.add(:logo, "Selected icon is not in correct format.")
      end  
    end if params[:theme].present? and params[:theme]["events_attributes"].present? and params[:theme]["events_attributes"]["0"].present? and params[:theme]["events_attributes"]["0"]["logo"].present?
  end

  def check_footer_image_error
    if params[:theme]["events_attributes"]["1"]["footer_image"].content_type != "image/png"
      if @event.errors.messages.present?
        if @event.errors.messages[:footer_image].present? and @event.errors.messages[:footer_image][1].present?
          @event.errors.messages[:footer_image][1] = "Selected icon is not in correct format."
        else
          @event.errors.add(:footer_image, "Selected icon is not in correct format.")
        end
      else  
        @event.errors.add(:footer_image, "Selected icon is not in correct format.")
      end  
    end if params[:theme].present? and params[:theme]["events_attributes"].present? and params[:theme]["events_attributes"]["1"].present? and params[:theme]["events_attributes"]["1"]["footer_image"].present?
  end

  def check_event_inside_logo_error
    if params[:theme]["events_attributes"]["0"]["inside_logo"].content_type != "image/png"
      if @event.errors.messages.present?
        if @event.errors.messages[:inside_logo].present? and @event.errors.messages[:inside_logo][0].present?
          @event.errors.messages[:inside_logo][0] = "Selected icon is not in correct format." 
        else
          @event.errors.delete(:inside_logo)
          @event.errors.add(:inside_logo, "Selected icon is not in correct format.")
        end  
      else  
        @event.errors.delete(:inside_logo)
        @event.errors.add(:inside_logo, "Selected icon is not in correct format.")
      end
    end if params[:theme].present? and params[:theme]["events_attributes"].present? and params[:theme]["events_attributes"]["0"].present? and params[:theme]["events_attributes"]["0"]["inside_logo"].present? 
  end

  # def check_attachment_type
  #   hsh = {'jpeg' => 'jpg', 'jpg' => 'jpg', 'doc' => 'docx', 'docb' => 'docb', 'docm' => 'docx', 'dotm' => 'docx', 'docx' => 'docx', 'xls' => 'xls', 'xlsx' => 'xlsx', 'pdf' => 'pdf', 'ppt' => 'ppt', 'pptx' => 'pptx', 'msword' => 'docx', 'vnd.ms-powerpoint' => 'ppt', 'vnd.openxmlformats-officedocument.presentationml.presentation' => 'ppt', 'octet-stream' => 'xls', 'vnd.openxmlformats-officedocument.spreadsheetml.sheet' => 'xls', 'vnd.ms-excel' => 'xls', 'vnd.openxmlformats-officedocument.wordprocessingml.document' => 'docx'}
  #   file_type = self.attachment_content_type.split("/").last rescue ""
  #   if hsh.key?(file_type) == false
  #     errors.add(:attachment, "Please select valid file format.")
  #   end
  # end

end
