class Admin::QnaSettingsController < ApplicationController
  layout 'admin'

  #load_and_authorize_resource
  before_filter :authenticate_user, :authorize_event_role, :find_features

  def index
    if @qna_settings.present?
      redirect_to edit_admin_event_qna_setting_path(:event_id => @qna_settings.first.event_id,:id => @qna_settings.first.id)
    else
      redirect_to new_admin_event_qna_setting_path(:event_id => @qna_setting.event_id)
    end
  end

  def new
    @qna_setting = @event.qna_settings.build
  end

  def create
    @qna_setting = @event.qna_settings.build(qna_setting_params)
    if @qna_setting.save
      redirect_to admin_event_qnas_path(:event_id => @qna_setting.event_id)
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @qna_setting.update_attributes(qna_setting_params)
      redirect_to admin_event_qnas_path(:event_id => @qna_setting.event_id)
    else
      render :action => "edit"
    end
  end

  def show
  end

  def destroy
    if @qna_setting.destroy
      redirect_to admin_event_qnas_path(:event_id => @qna_setting.event_id)
    end
  end

  protected

  def qna_setting_params
    params.require(:qna_setting).permit!
  end

end
