class Admin::MyTravelsController < ApplicationController
  layout 'admin'

  load_and_authorize_resource
  before_filter :authenticate_user, :authorize_event_role, :find_features
  before_filter :check_for_access, :only => [:index,:new]
  before_filter :check_user_role, :except => [:index,:new]

  def index
    @my_travels = @my_travels.paginate(:page => params[:page], :per_page => 10) if params["format"] != "xls"
    respond_to do |format|
      format.html  
      format.xls do
        method_allowed = [:Invitee_email, :File_Name_1, :File_1_URL, :File_Name_2, :File_2_URL, :File_Name_3, :File_3_URL, :File_Name_4, :File_4_URL,:File_Name_5,:File_5_URL,:Comment_box]
        send_data @my_travels.to_xls(:methods => method_allowed, :filename => "asd.xls")
      end
    end
  end
  def new
    @my_travel = @event.my_travels.build
    @import = Import.new if params[:import].present?
  end
  def create
    @my_travel = MyTravel.find_or_initialize_by(:event_id => @event.id,:invitee_id => params[:my_travel][:invitee_id])
    @my_travel.attach_file = params[:my_travel][:attach_file]
    @my_travel.attach_file_1_name = params[:my_travel][:attach_file_1_name]
    @my_travel.attach_file_2 = params[:my_travel][:attach_file_2] if params[:my_travel][:attach_file_2].present?
    @my_travel.attach_file_2_name = params[:my_travel][:attach_file_2_name] if params[:my_travel][:attach_file_2_name].present?
    @my_travel.attach_file_3 = params[:my_travel][:attach_file_3] if params[:my_travel][:attach_file_3].present?
    @my_travel.attach_file_3_name = params[:my_travel][:attach_file_3_name] if params[:my_travel][:attach_file_3_name].present?
    @my_travel.attach_file_4 = params[:my_travel][:attach_file_4] if params[:my_travel][:attach_file_4].present?
    @my_travel.attach_file_4_name = params[:my_travel][:attach_file_4_name] if params[:my_travel][:attach_file_4_name].present?
    @my_travel.attach_file_5 = params[:my_travel][:attach_file_5] if params[:my_travel][:attach_file_5].present?
    @my_travel.attach_file_5_name = params[:my_travel][:attach_file_5_name] if params[:my_travel][:attach_file_5_name].present?
    @my_travel.comment_box = params[:my_travel][:comment_box]
    if @my_travel.save
      redirect_to admin_event_my_travels_path(:event_id => @event.id)
    else
      render :action => 'new'
    end
  end

  def edit
    
  end
  def update
    if params[:remove_image] == "true"
      @my_travel.update_attribute(:attach_file, nil) if @my_travel.attach_file.present? and params[:file_field_name] == "attach_file"
      @my_travel.update_attribute(:attach_file_2, nil) if @my_travel.attach_file_2.present? and params[:file_field_name] == "attach_file_2"
      @my_travel.update_attribute(:attach_file_3, nil) if @my_travel.attach_file_3.present? and params[:file_field_name] == "attach_file_3"
      @my_travel.update_attribute(:attach_file_4, nil) if @my_travel.attach_file_4.present? and params[:file_field_name] == "attach_file_4"
      @my_travel.update_attribute(:attach_file_5, nil) if @my_travel.attach_file_5.present? and params[:file_field_name] == "attach_file_5"
      redirect_to edit_admin_event_my_travel_path(:event_id => @event.id, :id => @my_travel.id)
    else
      if @my_travel.update_attributes(my_travel_params)
        redirect_to admin_event_my_travels_path(:event_id => @event.id)
      else
        render :action => "edit"
      end
    end 
  end

  def destroy
    if @my_travel.destroy
      redirect_to admin_event_my_travels_path(:event_id => @event.id)
    end
  end
  


  protected

  def my_travel_params
    params.require(:my_travel).permit!
  end
  def check_user_role
    if (!current_user.has_role_for_event?("db_manager", @event.id,session[:current_user_role])) #(!current_user.has_role? :db_manager) 
      redirect_to admin_dashboards_path
    end  
  end
end
