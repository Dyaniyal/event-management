class Admin::ContactsController < ApplicationController
layout 'admin'
before_filter :authenticate_user, :authorize_event_role, :find_features

  def index
    @contacts = @contacts.reverse.paginate(page: params[:page], per_page: 10)
  end

  def new
    @contact = @event.contacts.build
  end

  def create
    @contact = @event.contacts.build(contact_params)
    if @contact.save
      if params[:from] == "microsites"
        redirect_to admin_event_microsite_path(:event_id => @event.id, :id => @event.microsite.id, :type => "show_content")
      elsif params[:type].present?
        redirect_to admin_event_mobile_application_path(:event_id => @event.id,:id => @event.mobile_application_id,:type => "show_content")
      else
        redirect_to admin_event_contacts_path(:event_id => @contact.event_id)
      end
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @contact.update_attributes(contact_params)
      if params[:from] == "microsites"
        redirect_to admin_event_contacts_path(:event_id => @contact.event_id, :from => "microsites")
      else
        redirect_to admin_event_contacts_path(:event_id => @contact.event_id)
      end
    else
      render :action => "edit"
    end
  end

  def show
  end

  def destroy
    if @contact.destroy
      if params[:from] == "microsites"
        redirect_to admin_event_contacts_path(:event_id => @contact.event_id, :from => "microsites")
      else
        redirect_to admin_event_contacts_path(:event_id => @contact.event_id)
      end
    end
  end

  protected
  def contact_params
    params.require(:contact).permit!
  end

end

