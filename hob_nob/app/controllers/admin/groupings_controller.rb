class Admin::GroupingsController < ApplicationController
  layout 'admin'
  #load_and_authorize_resource
  before_filter :authenticate_user, :authorize_event_role, :find_features
  before_action :set_grouping_fields_validations, :only => [:new, :edit, :update, :create]
  before_action :find_grouping_data, :only => [:index, :show]
  before_filter :check_user_role#, :except => [:index] 

  def index
    if params[:format].present?
      respond_to do |format|
        format.html  
        format.xls do
          method_allowed = []
          for invitee in @invitee_datum
            arr = @only_columns.map{|c| invitee.attributes[c]}
            @export_array << arr
          end
          send_data @export_array.to_reports_xls
        end
      end
    else
      redirect_to admin_event_invitee_structures_path(:event_id => @event.id)
    end
  end

  def new
    @grouping = @event.groupings.new
  end

  def create
    @grouping = @event.groupings.build(grouping_params)
    if @grouping.save
      redirect_to admin_event_invitee_structures_path(:event_id => @event.id)
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @grouping.update(grouping_params)
      redirect_to admin_event_invitee_structures_path(:event_id => @event.id)
    else
      render :action => "edit"
    end
  end

  def destroy
    if params[:group] == "all"
      @invitee_structure = @event.invitee_structures.last
      @grouping.get_search_data_count(InviteeDatum.where(:invitee_structure_id => @invitee_structure.id)).destroy_all
      redirect_to admin_event_invitee_structures_path(:event_id => @event.id)  
    elsif params[:invitee_data] == "all"
      @invitee_structure = @event.invitee_structures.last
      @invitee_datum_all = InviteeDatum.where(:invitee_structure_id => @invitee_structure.id)
      if @invitee_datum_all.present?
        @grouping.get_search_data_count(@invitee_datum_all).destroy_all
        redirect_to admin_event_invitee_structures_path(:event_id => @event.id)
      end
    else 
      @grouping.destroy
      redirect_to admin_event_invitee_structures_path(:event_id => @event.id)
   end
  end

  def show
    respond_to do |format|
      format.html  
      format.xls do
        method_allowed = []
        for invitee in @invitee_datum
          arr = @only_columns.map{|c| c == "telecaller_update_count" ? invitee.telecaller_update_count.present? : c == "opt_unsubscribe" ? invitee.opt_unsubscribe.present? : invitee.attributes[c]}
          arr = arr.map{|x| x == true ? 'Yes' : x == false ? 'No' : x}
          arr = arr.map{|x| x == true ? 'Yes' : x == false ? 'No' : x}
          @export_array << arr
        end
        send_data @export_array.to_reports_xls, filename: "#{@grouping.name.gsub(' ', '_') rescue 'Grouping'}.xls"
      end
    end
  end

  private

  def set_grouping_fields_validations
    @fields = Grouping.get_default_grouping_fields(@event)
    @validations = Grouping.default_validation
  end

  def find_grouping_data
    if params[:format].present?
      @grouping = Grouping.where(:event_id => @event.id, :id => params[:id]).last
      @invitee_structure = @event.invitee_structures.last
      columns = @invitee_structure.attributes.except('id','created_at','updated_at','event_id','uniq_identifier')
      @only_columns = @invitee_structure.get_selected_column + ["status","reported_status","remark","registration_status","telecaller_update_count","opt_unsubscribe","consent_question_1", "consent_answer_1", "consent_question_2", "consent_answer_2", "consent_question_3", "consent_answer_3", "consent_question_4", "consent_answer_4", "consent_question_5", "consent_answer_5", "consent_question_6", "consent_answer_6", "consent_question_7", "consent_answer_7", "consent_question_8", "consent_answer_8", "consent_question_9", "consent_answer_9", "consent_question_10", "consent_answer_10","consent_questions_answered_time"]
      header_columns = @only_columns.map{|c| columns[c]}.compact + ["Call status","Reported status","Remarks","Registration status","Data Updated","Opt Unsubscribe","TC Consent Question 1", "TC Consent Answer 1", "TC Consent Question 2", "TC Consent Answer 2", "TC Consent Question 3", "TC Consent Answer 3", "TC Consent Question 4", "TC Consent Answer 4", "TC Consent Question 5", "TC Consent Answer 5", "TC Consent Question 6", "TC Consent Answer 6", "TC Consent Question 7", "TC Consent Answer 7", "TC Consent Question 8", "TC Consent Answer 8", "TC Consent Question 9", "TC Consent Answer 9", "TC Consent Question 10", "TC Consent Answer 10","Consent Questions Answered Timestamp"]
      @invitee_datum = @grouping.get_search_data_count(InviteeDatum.where(:invitee_structure_id => @invitee_structure.id))
      @export_array = [header_columns] 
    end  
  end
  def grouping_params
    params[:grouping].permit!
  end

  def check_user_role
    if !(current_user.has_role_for_event?("db_manager", @event.id,session[:current_user_role]) || current_user.has_role_for_event?("response_manager", @event.id,session[:current_user_role]))
      redirect_to admin_dashboards_path
    end  
  end
end