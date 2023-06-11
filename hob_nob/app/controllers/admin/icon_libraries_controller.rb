class Admin::IconLibrariesController < ApplicationController
  layout 'admin'
  load_and_authorize_resource
  before_filter :check_user_is_licensee
  before_filter :authenticate_user,:get_licensee_data
  
  def index
    @icon_libraries = IconLibrary.where(:licensee_id => @licensee.id)
  end

  def new
    # default_fields = ["abouts", "agendas", "speakers", "faqs", "galleries", "feedbacks", "e_kits", "conversations", "polls", "awards", "invitees", "qnas", "notes", "contacts", "sponsors", "my_profile", "qr_code", "quizzes", "favourites", "venue", "leaderboard", "custom_page1s", "custom_page2s", "custom_page3s", "custom_page4s", "custom_page5s", "chats", "activity_feeds", "my_travels", "exhibitors", "all_events"]
    default_fields = ["abouts", "agendas", "speakers", "faqs", "galleries", "feedbacks", "e_kits", "conversations", "polls", "awards", "invitees", "qnas", "notes", "contacts", "sponsors", "my_profile", "qr_code", "quizzes", "favourites", "venue", "leaderboard", "chats", "activity_feeds", "my_travels", "exhibitors", "all_events","maps"]
    @icon_library = @licensee.icon_libraries.build
    default_fields.each do |default_field|
      @icons = @icon_library.icons.build(:icon_name => default_field)
    end
  end

  def create
    @icon_library = @licensee.icon_libraries.build(icon_library_params)
    if @icon_library.save
      redirect_to admin_icon_libraries_path
    else
      render :action => 'new'
    end
  end

  def edit
    
  end

  def update
    if @icon_library.update_attributes(icon_library_params)
      redirect_to admin_icon_libraries_path
    else
      render :action => "edit"
    end
  end

  def show
  end

  def destroy
    if @icon_library.destroy
      redirect_to admin_icon_libraries_path
    end
  end

  protected

  def icon_library_params
    params.require(:icon_library).permit!
  end

  def get_licensee_data
    # if current_user.has_role?("licensee_admin")
    @licensee = User.find(current_user.get_licensee)
    # end
  end

  def check_user_is_licensee
    redirect_to admin_dashboards_path if (!current_user.has_role?("licensee_admin"))
  end
end

