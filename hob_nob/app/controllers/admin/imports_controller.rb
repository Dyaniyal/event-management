class Admin::ImportsController < ApplicationController
  layout 'admin'
  require 'excel_invitee'
  require 'excel_import_attendees'
  require 'excel_import_feedback'
  require 'excel_import_users_feedbacks'
  require 'excel_import_users_comments'
  require 'excel_import_users_likes'
  require 'excel_import_poll'
  require 'excel_import_users_polls'
  require 'excel_import_qna'
  require 'excel_import_conversation'
  require 'excel_import_invitee_data'
  require 'excel_import_speakers'
  require 'excel_import_agendas'
  require 'excel_import_my_travels'
  require 'excel_import_user_registration'
  require 'excel_import_auto_status_email'
  require 'excel_import_unsubscribe_data'
  #load_and_authorize_resource
  before_filter :authenticate_user, :authorize_event_role#, :find_features
  before_filter :check_for_access, :only => [:index,:new]

  def index
    @imports = Import.where(importable_type: 'invitee_data').not_rejected
    @imports = @imports.where(importable_id: params[:event_id]) unless params[:all] == "1"
    @imports = @imports.paginate(page: params[:page], per_page: 10)
  end

  def new
    @import = Import.new
    if params[:importable_type_sample].present?
      redirect_to "/#{params[:importable_type_sample]}"
    end
  end

  def create
    @import = Import.new(import_params)
    if params[:import][:importable_type] == 'invitee_data'
      if @import.save
        @import.update_row_count
        redirect_to admin_event_imports_path(event_id: @import.importable_id)
      else
        render redirect_hash(params[:import][:importable_type], " ")["template"]
      end
    elsif @import.save
      import_attribs = params[:import][:importable_type].classify.constantize.column_names unless params[:import][:importable_type] == "variant_product"
      import_options = { start_row: 2, generate_status: params[:status], import: @import.id }
      if params[:registration_type].present? and (params[:registration_type] == "auto_approve" or params[:registration_type] == "auto_reject") 
        import_result = decide_import_structure_user_registraion(@import.import_file.url.split("?").first, params[:import][:importable_type], params[:import][:importable_id].to_i,import_attribs, import_options,params[:registration_type])
      else
        import_result = decide_import_structure(@import.import_file.url.split("?").first, params[:import][:importable_type], params[:import][:importable_id].to_i,import_attribs, import_options)
      end
      if params[:from] == "microsites" and  import_result[:is_saved] == true
        @import = Import.new
        flash[:notice] = "File uploaded successfully."
        redirect_to redirect_hash1(params[:import][:importable_type],import_result[:excel_errors])["url"]
      elsif import_result[:is_saved] == true
        @import = Import.new
        flash[:notice] = "File uploaded successfully."
        redirect_to redirect_hash(params[:import][:importable_type],import_result[:excel_errors])["url"]
      else
        params[:importable_type] = params[:import][:importable_type]
        render redirect_hash(params[:import][:importable_type],import_result[:excel_errors])["template"]
      end
    elsif params[:import][:importable_type].present? and redirect_hash(params[:import][:importable_type]).present?
      render redirect_hash(params[:import][:importable_type], " ")["template"]
    else
      render '/admin/imports/new'
    end
  end

  protected

  def import_params
    params.require(:import).permit!
  end
  def redirect_hash1(model_name, excel_errors= " ")
    @error_import = excel_errors rescue " "
    hsh = {
      "speaker" => { "url" => admin_event_speakers_path(:event_id => params[:import][:importable_id].to_i, :from => "microsites"), "template" => '/admin/imports/new' },
      "agenda" => { "url" => admin_event_agendas_path(:event_id => params[:import][:importable_id].to_i, :from => "microsites"), "template" => '/admin/imports/new' }           
    }
    hsh[model_name]
  end
  def redirect_hash(model_name, excel_errors= " ")
    @error_import = excel_errors rescue " "
    hsh = {
      "invitee" => { "url" => admin_event_invitees_path(:event_id => params[:import][:importable_id].to_i), "template" => '/admin/imports/new' },
      "invitee_data" => { "url" => admin_event_invitee_structures_path(:event_id => params[:import][:importable_id].to_i), "template" => '/admin/imports/new' },
      "attendee" => { "url" => admin_event_attendees_path(:event_id => params[:import][:importable_id].to_i), "template" => '/admin/imports/new' },
      "user_polls" => { "url" => admin_event_polls_path(:event_id => params[:import][:importable_id].to_i), "template" => '/admin/imports/new' },
      "user_feedbacks" => { "url" => admin_event_feedbacks_path(:event_id => params[:import][:importable_id].to_i), "template" => '/admin/imports/new' },               
      "poll" => { "url" => admin_event_polls_path(:event_id => params[:import][:importable_id].to_i), "template" => '/admin/imports/new' },
      "conversation" => { "url" => admin_event_conversations_path(:event_id => params[:import][:importable_id].to_i), "template" => '/admin/imports/new' },
      "comments" => { "url" => admin_event_conversations_path(:event_id => params[:import][:importable_id].to_i), "template" => '/admin/imports/new' },
      "likes" => { "url" => admin_event_conversations_path(:event_id => params[:import][:importable_id].to_i), "template" => '/admin/imports/new' },
      "qna" => { "url" => admin_event_qnas_path(:event_id => params[:import][:importable_id].to_i), "template" => '/admin/imports/new' },
      "feedback" => { "url" => admin_event_feedbacks_path(:event_id => params[:import][:importable_id].to_i), "template" => '/admin/imports/new' },
      "speaker" => { "url" => admin_event_speakers_path(:event_id => params[:import][:importable_id].to_i), "template" => '/admin/imports/new' },
      "agenda" => { "url" => admin_event_agendas_path(:event_id => params[:import][:importable_id].to_i), "template" => '/admin/imports/new' }, 
      "my_travel" => { "url" => admin_event_my_travels_path(:event_id => params[:import][:importable_id].to_i), "template" => '/admin/imports/new' },
      "user_registration" => { "url" =>  admin_event_user_registrations_path(:event_id => params[:import][:importable_id].to_i), "template" => '/admin/imports/new' },
      "auto_status_email" => { "url" => admin_event_user_registrations_path(:event_id => params[:import][:importable_id].to_i), "template" => '/admin/imports/new' } ,  
      "unsubscribe" => { "url" => admin_event_unsubscribes_path(:event_id => params[:import][:importable_id].to_i), "template" => '/admin/imports/new'}           
    }
    hsh[model_name]
  end

  def decide_import_structure(file_url, type, importable_id,import_attribs, import_options)
    lib_klass = {
                  invitee: ExcelInvitee, invitee_data: ExcelImportInviteeData, poll: ExcelImportPoll,
                  user_polls: ExcelImportUserPoll, conversation: ExcelImportConversation, qna: ExcelImportQna,
                  attendee: ExcelImportAttendees, feedback: ExcelImportFeedback, user_feedbacks: ExcelImportUserFeedback,
                  comments: ExcelImportUserComment, likes: ExcelImportUserLike, speaker: ExcelImportSpeaker, agenda: ExcelImportAgenda,
                  my_travel: ExcelImportMyTravel, user_registration: ExcelImportUserRegistration, unsubscribe: ExcelImportUnsubscribeData
                }
    import_result = lib_klass[type.to_sym].save(file_url, type, importable_id, import_attribs, 'add', import_options)
  end

  def decide_import_structure_user_registraion(file_url, type, importable_id,import_attribs, import_options,registration_type)
    import_result = ExcelImportAutoStatusEmail.save(file_url, type, importable_id, import_attribs, 'add', import_options,registration_type) 
  end 

end
