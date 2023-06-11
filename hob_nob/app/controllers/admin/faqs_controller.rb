class Admin::FaqsController < ApplicationController
  layout 'admin'

  load_and_authorize_resource
  before_filter :authenticate_user, :authorize_event_role, :find_features
  
	def index
    @faqs = Faq.search(params,@faqs) if params[:search].present?
    #@faqs = @faqs.paginate(page: params[:page], per_page: 10)
	end

	def new
		@faq = @event.faqs.build
	end

	def create
    @faq = @event.faqs.build(faq_params)
    if @faq.save
      if params[:from] == "microsites"
        redirect_to admin_event_microsite_path(:event_id => @event.id, :id => @event.microsite.id, :type => "show_content")
      elsif params[:type].present?
        redirect_to admin_event_mobile_application_path(:event_id => @event.id,:id => @event.mobile_application_id,:type => "show_content")
      else
        redirect_to admin_event_faqs_path(:event_id => @faq.event_id)
      end
    else
      render :action => 'new'
    end
	end

	def edit
	end

	def update
		if @faq.update_attributes(faq_params)
      if params[:from] == "microsites"
        redirect_to admin_event_faqs_path(:event_id => @faq.event_id, :from => "microsites")
      else
        redirect_to admin_event_faqs_path(:event_id => @faq.event_id)
      end
    else
      render :action => "edit"
    end
	end

	def show
  end

  def destroy
    if @faq.destroy
      if params[:from] == "microsites"
        redirect_to admin_event_faqs_path(:event_id => @faq.event_id, :from => "microsites")
      else
        redirect_to admin_event_faqs_path(:event_id => @faq.event_id)
      end
    end
  end

	protected

  def faq_params
    params.require(:faq).permit!
  end

end
