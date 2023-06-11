module ApplicationHelper

  def get_percentage(num, poll, bar_color, poll_wall, size, percentage)
   result= "<p style='color:"+poll_wall.font_color+"'>"
   (num.is_a? Numeric) ? result+= num.to_s : result+= poll.send(num)
   percentage = get_user_poll_percentage(num.to_s,poll)
   result+= "</p>"
   result+= "<div class='progress'>"
   result+= "<div class='pollwidth' style='width: 90%'>"
   result+= "<div class='progress-bar progress-bar-2' style='width: "+percentage.to_s+"%; background-color: "+bar_color+";' role='progressbar' aria-valuemax='' aria-valuemin='0'  aria-valuenow="+size.to_s+" >"
   result+= "</div></div>"
   result+= "<span style='color: "+poll_wall.font_color+"'>" 
   result+= percentage.to_s + '%' 
   result+= "</span>"
   result+= "</div>"
   bar_color = ((bar_color == poll_wall.bar_color)? poll_wall.bar_color1 : poll_wall.bar_color) if percentage.present? and percentage != 0  
   return result.html_safe
  end

  def get_default_poll_wall_get_percentage(num, poll, size, percentage)
    result= "<p style='color:""'>"
     (num.is_a? Numeric) ? result+= num.to_s : result+= poll.send(num)
     percentage = get_user_poll_percentage(num.to_s,poll)
    result+= "</p>"
    result+= "<div class='progress'>"
    result+= "<div class='pollwidth' style='width: 90%'>"
    result+= "<div class='progress-bar progress-bar-2' style='width: "+percentage.to_s+"%; background-color: "";' role='progressbar' aria-valuemax='' aria-valuemin='0'  aria-valuenow="+size.to_s+" >"
    result+= "</div></div>"
    result+= "<span style='color: ""'>" 
    result+= percentage.to_s + '%' 
    result+= "</span>"
    result+= "</div>"
    #bar_color = ((bar_color == poll_wall.bar_color)? poll_wall.bar_color1 : poll_wall.bar_color) if percentage.present? and percentage != 0  
    return result.html_safe
  end

  def add_fields_for_agenda_speakers(name, f, association, disp, partial = "agenda_speakers_fields", locals = {}, klass)
    new_object = association.to_s.classify.constantize.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      locals[:f] = builder
      locals[:disp] = disp
      render(:partial => partial, :locals => locals)
    end
    link_to name, 'javascript:void(0);', :class => klass, :onclick => "add_fields_for_agenda_speakers(this, \"#{association}\", \"#{escape_javascript(fields)}\")"
  end

  def time_with_zone(datetime, zone=nil,format)
    if zone.present? and zone == 'IST'# and format == "%Y-%m-%d %H:%M"
      datetime.to_time.in_time_zone('Kolkata').strftime(format) if datetime.present?
    elsif zone.present?
      datetime.to_time.in_time_zone(zone).strftime(format) if datetime.present?
    else
      datetime.to_time.utc.strftime('%Y-%m-%d %H:%M') if datetime.present?
    end
  end

  def formatted_time(datetime, date_format)
    datetime.strftime(date_format) if datetime.present?
  end

  def break_line
    str = "<br><br><br>"
  end

  def get_only_time_in_ampm(time)
    time.to_time.in_time_zone('Kolkata').strftime('%I:%M %p') rescue nil
  end

  def get_datetime_with_ist_timezone(datetime)
    #datetime.in_time_zone('Kolkata') if datetime.present?
    datetime.in_time_zone('Kolkata').strftime('%Y-%m-%d %H:%M') if datetime.present?
  end


  def get_status_button(f, status, icon_name)
    url = update_status_admin_licensee_path(:id => f.id, :status => status)
    html_content = content_tag(:i, icon_name, :class => "material-icons center")
    link_to html_content, url, :class => "col-md-6 btn back_button", :confirm =>'Are you sure?', :style => "float:right;width:80px"
  end

  def admin_event_color(event)
    date = "" 
    if event.start_event_date.present? and event.end_event_date.present? and event.start_event_date > Date.today
      color = "green_1"
    elsif event.start_event_date.present? and event.end_event_date.present? and event.start_event_date < Date.today
      color = "red_1"
    else
      color = "yellow_1"
    end
    date = "<span class=#{color}>#{event.start_event_date.strftime("%b %d, %Y")}  To  #{event.end_event_date.strftime("%b %d, %Y")}</span>"
    return date.html_safe 
  end

  def back_button(url = :back)
    url = back_path if url == :back
    html_content = content_tag(:span, "Cancel", :class => "waves-effect waves-light btn")
    link_to html_content, url, :confirm =>'Are you sure?'#,:style => "float:right;width:120px"
  end  

  def back_button_detailed_page(url = :back)
    url = back_path if url == :back
    html_content = content_tag(:span, "Back", :class => "back_btn")
    link_to html_content, url, :confirm =>'Are you sure?'
  end

  #def time_with_zone(datetime, zone=nil)
  #  if zone.present? and zone == 'IST'
  #    datetime.to_time.in_time_zone('Kolkata').strftime('%Y-%m-%d %H:%M') rescue nil
  #  else
  #    datetime.to_time.utc.strftime('%Y-%m-%d %H:%M') rescue nil
  #  end
  #end

  def time_with_zone(datetime, zone=nil)
    if zone.present? and zone == 'IST'
      datetime.to_time.in_time_zone('Kolkata').strftime('%Y-%m-%d %H:%M') rescue nil
    else
      datetime.to_time.utc.strftime('%Y-%m-%d %H:%M') rescue nil
    end
  end

  def get_hour_minute_second_ampm(time, format)
    case format
    when 'hour'
      time.strftime('%l').strip.rjust(2, '0') rescue nil
    when 'minute'
      time.strftime('%M').strip.rjust(2, '0') rescue nil
    when 'second'
      time.strftime('%S').strip.rjust(2, '0') rescue nil
    when 'ampm'
      time.strftime('%p').strip.rjust(2, '0') rescue nil
    end
  end

  def date_with_zone(datetime, zone=nil)
    if zone.present? and zone == 'IST'
      datetime.to_time.in_time_zone('Kolkata').strftime('%d %b %Y') rescue nil
    else
      datetime.to_time.utc.strftime('%d %b %Y') rescue nil
    end
  end
  
  def get_only_time_in_ampm(time)
    time.to_time.in_time_zone('Kolkata').strftime('%I:%M %p') rescue nil
  end

  def get_datetime(time)
    time.to_time.in_time_zone('Kolkata').strftime('%d-%m-%Y %H:%M') rescue nil
  end

  def get_datetime_in_ampm(time)
    time.to_time.in_time_zone('Kolkata').strftime('%d-%m-%Y %I:%M %p') rescue nil
  end

  def back_button_detailed_page(url = :back)
    url = back_path if url == :back
    html_content = content_tag(:span, "Back", :class => "back_btn")
    link_to html_content, url, :confirm =>'Are you sure?'
  end 

  def ul_setup(ui_action,ui_controler) 
    #checking_collaps = ["admin/events","admin/speakers","admin/attendees","admin/invitees","admin/agendas","admin/polls","admin/conversations","admin/faqs", "admin/images", "admin/sponsors","admin/awards", "admin/feedbacks", "admin/qnas", "admin/e_kits" , "admin/themes", "admin/contacts", "admin/notifications", "admin/panels", "admin/highlight_images", "admin/abouts", "admin/event_highlights", "admin/emergency_exits", "admin/event_features"]
    #value = (checking_collaps.include?(ui_controler) and ui_action == ui_action and params[:event_id].present?)  ? "flex" : "none" 
    #value = "none" if (params[:controller] == "admin/mobile_applications" and ["new" , "create", "index"].include? params[:action])
    value = @event.present? ? "flex" : "none" 
    return value 
  end

  def get_analytic_details(type, id)
    hsh = {'top_fav_agendas' => ['Agenda', 'title'], 'top_rated_agendas' => ['Agenda', 'title'], 'top_viewed_ekits' => ['EKit', 'name'], 'top_liked_conversations' => ['Conversation', 'description'], 'top_commented_conversations' => ['Conversation', 'description'], 'top_answered_polls' => ['Poll', 'question'], 'top_fav_invitees' => ['Invitee', 'name_of_the_invitee'], 'top_fav_sponsors' => ['Sponsor', 'name'], 'top_viewed_sponsors' => ['Sponsor', 'name'], 'top_fav_exhibitors' => ['Exhibitor', 'name'], 'top_viewed_exhibitors' => ['Exhibitor', 'name'], 'top_answered_quizzes' => ['Quiz', 'question'], 'top_rated_speakers' => ['Speaker', 'speaker_name'], 'top_fav_speakers' => ['Speaker', 'speaker_name'], 'top_question_speakers' => ['Panel', 'name'], 'top_fav_leaderboard' => ['Invitee', 'name_of_the_invitee']}
    obj = hsh[type][0].singularize.constantize.find_by_id(id)
    [obj, hsh[type][1]]
  end


  def link_to_remove_fields(name, f)
    f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)")
  end

  def link_to_add_image(name, f, association, partial = "images_fields", locals = {})
    new_object = association.to_s.classify.constantize.new
    fields = f.fields_for(association, new_object, :child_index => "new_{association}") do |builder|
      locals[:f] = builder
      render(:partial => partial, :locals => locals)
    end
    link_to "Add More Images", 'javascript:void(0);', :onclick => "add_fields(this, \"{association}\", \"#{escape_javascript(fields)}\")", :class => 'add_more_image'
  end
  
  def get_feature_url(feature, params)
    url = "javascript:void();"
    single_associate = ["abouts", "event_highlights", "emergency_exits","maps"]
    single_associate_redirect = "/new" if single_associate.include?(feature)
    if params[:controller] == "admin/themes" and params[:step] == "event_theme" 
      url = "/admin/events/#{params[:event_id]}/themes/#{params[:id]}/edit?step=#{params[:step]}" if params[:id].present?
      url = "/admin/events/#{params[:event_id]}/themes/new?step=event_theme" if (params[:id].blank? and params[:action] == "new")
    elsif params[:controller] == "admin/winners"
      url = "/admin/events/#{params[:event_id]}/awards/#{params[:award_id]}/winners"
    elsif params[:controller] == "admin/edms"
       url = "/admin/events/#{params[:event_id]}/campaigns/#{params[:campaign_id]}/edms" 
    elsif params[:controller] ==  "admin/consent_question_look_and_feels"
      url = "/admin/events/#{params[:event_id]}/mobile_applications/#{params[:mobile_application_id]}/consent_question_look_and_feels/new"
    elsif params[:controller] == "admin/mobile_consent_questions"
      url = "/admin/events/#{params[:event_id]}/mobile_applications/#{params[:mobile_application_id]}/mobile_consent_questions"
    elsif params[:event_id].present?
      url ="/admin/events/#{params[:event_id]}/#{feature}?role=all" if params[:role] == "all" || params[:get_role] == "all"
      url = "/admin/events/#{params[:event_id]}/#{feature}#{single_associate_redirect}" if params[:role] != "all" and params[:get_role] != "all"
    elsif params[:id].present? and params[:controller] == 'admin/events'
      url = "/admin/events/#{params[:id]}/#{feature}#{single_associate_redirect}"
    elsif params[:client_id].present? 
      url = admin_client_events_path(:client_id => params[:client_id], :feature => feature) 
    else
      url = admin_clients_path(:feature => feature)
    end
    url
  end
  def get_microsite_feature_url(feature, params)
    url = "javascript:void();"
    single_associate = ["abouts", "emergency_exits"]
    single_associate_redirect = "/new" if single_associate.include?(feature)
    if params[:event_id].present?
      url ="/admin/events/#{params[:event_id]}/#{feature}?role=all" if params[:role] == "all" || params[:get_role] == "all"
      url = "/admin/events/#{params[:event_id]}/#{feature}#{single_associate_redirect}?from=microsites" if params[:role] != "all" and params[:get_role] != "all"
    elsif params[:id].present? and params[:controller] == 'admin/events'
      url = "/admin/events/#{params[:id]}/#{feature}#{single_associate_redirect}"
    end
    url
  end

  def get_client_feature_url(feature, params)
    admin_clients_path(:feature => feature)
  end

  def get_event_feature_url(feature, params)
    if params[:client_id].present?
      admin_client_events_path(:client_id => params[:client_id], :feature => feature) 
    elsif params[:event_id].present? and !params[:client].present?
      client_id = Event.find(params[:event_id]).client.id rescue nil
      admin_client_events_path(:client_id => client_id, :feature => feature)
    else
      "/admin/events/#{params[:event_id]}/#{feature}"   
    end  
  end

  def get_tab_event_feature_url(feature, params)
    if params[:event_id].present? and params[:client_id].blank?
      admin_clients_path(:feature => "events")
    elsif params[:client_id].present? 
      admin_client_events_path(:client_id => params[:client_id]) 
    else
      admin_clients_path(:feature => "events")
    end
  end
  
  def agenda_group(agendas)
    data =  {}
    keys = @agenda_group_by_start_agenda_time.count
    keys.each do |key,value|
      data[key] = @agendas.where('Date(start_agenda_date) = ?', key) if key.present?
    end
    data
  end 

  def agenda_date(event)
    data =  {}
    keys = event.agendas.group("DATE(start_agenda_time)").count
    keys.each do |key,value|
      data[key] = event.agendas.where('Date(start_agenda_date) = ?', key) if key.present?
    end
    data
  end 

  def event_type(event)
    if [345, 360, 367, 173, 165, 168, 364, 365, 368, 333].include? event.id
      if event.start_event_date.strftime('%d/%m/%Y %H:%M:%S').to_time <= Time.now.strftime('%d/%m/%Y %H:%M:%S').to_time and event.end_event_date.strftime('%d/%m/%Y %H:%M:%S').to_time >= Time.now.strftime('%d/%m/%Y %H:%M:%S').to_time
        "Ongoing"
      elsif event.start_event_date.strftime('%d/%m/%Y %H:%M:%S').to_time > Time.now.strftime('%d/%m/%Y %H:%M:%S').to_time and event.end_event_date.strftime('%d/%m/%Y %H:%M:%S').to_time > Time.now.strftime('%d/%m/%Y %H:%M:%S').to_time
        "Upcoming"
      else
        "Past"
      end
    else
      if event.start_event_date <= Time.now and event.end_event_date >= Time.now
        "Ongoing"
      elsif event.start_event_date > Time.now and event.end_event_date > Time.now
        "Upcoming"
      else
        "Past"
      end
    end
  end
   
  def show_field(label, obj)
    #mdl-cell--5-col mdl-cell--4-col-tablet m-8
    content_tag :div, class: "mdl-cell--5-col no-p-l no-p-t no-p-r no-p-b" do
      content_tag :div, class: "" do
        content_tag :p, class: "no-m-b" do
          str = content_tag :strong, label
          str += content_tag :span, obj ,:style=>"word-wrap: break-word;" rescue nil
          str
        end  
      end
    end    
  end


  def show_field_new(label, obj,percentage=nil, no_of_response=false)
    content_tag :div, class: "mdl-cell--8-col no-p-l no-p-t no-p-r no-p-b m-8" do
      content_tag :div, class: "" do
        content_tag :p, class: "no-m-b p-b-5" do
          str = content_tag :strong, label, :class => "pollstr"
          # str += content_tag :span, obj rescue nil
          str += content_tag :span," (#{find_option_percentage(percentage,obj) rescue nil})", :class =>"pollsWidth"
          str += content_tag :span, "Total number of Responses (#{correct_user_feedback_for_total_count(percentage,obj) rescue nil})",:class =>"pollsWidth2" if no_of_response == true
          str
        end  
      end
    end    
  end 

  def show_field_new_for_poll(label, obj,percentage=nil)
    content_tag :div, class: "mdl-cell--8-col no-p-l no-p-t no-p-r no-p-b m-8" do
      content_tag :div, class: "" do
        content_tag :p, class: "no-m-b p-b-5" do
          str = content_tag :strong, label, :class => "pollstr"
          str += content_tag :span, "(#{correct_user_polls_for_percentile(percentage,obj) rescue nil})", :class =>"pollsWidth"
          str += content_tag :span, "Total number of Responses (#{correct_user_polls_for_total_count(percentage,obj) rescue nil})",:class =>"pollsWidth2"
          str
        end  
      end
    end    
  end 

  def show_field_new_for_quiz(label, obj,percentage=nil)
    content_tag :div, class: "mdl-cell--8-col no-p-l no-p-t no-p-r no-p-b m-8" do
      content_tag :div, class: "" do
        content_tag :p, class: "no-m-b p-b-5" do
          str = content_tag :strong, label, :class => "pollstr"
          str += content_tag :span, "(#{correct_user_quizzes_for_percentile(percentage,obj) rescue nil})", :class =>"pollsWidth"
          str += content_tag :span, "Total number of Responses (#{correct_user_quizzes_for_total_count(percentage,obj) rescue nil})",:class =>"pollsWidth2"
          str
        end  
      end
    end    
  end 


  def show_field_newQuestion(label, obj)
    #mdl-cell--5-col mdl-cell--4-col-tablet m-8
    content_tag :div, class: "mdl-cell--12-col no-p-l no-p-t no-p-r no-p-b" do
      content_tag :div, class: "" do
        content_tag :p, class: "no-m-b p-b-2" do
          str = content_tag :strong, label
          str += content_tag :span, obj rescue nil
          str
        end  
      end
    end    
  end 
  

  
  # for advance search
  def custom_text_field_tag(name,title, params,*args)
    content_tag :div, class: "mdl-cell--4-col mdl-cell--4-col-tablet m-8" do
      content_tag :div, class: "mdl-textfield mdl-js-textfield mdl-textfield--floating-label is-upgraded" do
        str = content_tag(:input, nil, :type => 'text', :name => name, :value => params, :class => "mdl-textfield__input", :id => (args[0].present?) ? args[0][:id] : '')
        str += content_tag :label, title, class: "mdl-textfield__label"
        str
      end
    end
  end

  def custom_button_tag(title, label)
    content_tag :div, class: "mdl-cell--4-col mdl-cell--4-col-tablet mdl-cell--4-col-phone m-8" do
      content_tag :div, class: "moreBtn collapseminus" do
        str = content_tag :a, "Hide", class: "f-right m-t-5 hvr-underline-from-center hvr-underline-from-centernew", href: "javascript:void(0);" 
        str += content_tag(:input, nil, :type => 'submit', :value => title, :class => "mdl-button mdl-js-button mdl-button--raised mdl-button--colored mdl-js-ripple-effect mdl-color--light-blue-600 f-right m-r-35") 
        str
      end
    end
  end

  def custom_button_tag_eventsearch(title, label)
    # content_tag :div, class: "mdl-cell--4-col mdl-cell--4-col-tablet m-8" do
      # content_tag :div, class: "moreBtn collapseminus" do
        str = content_tag :a, "Hide", class: "f-right m-t-5 hvr-underline-from-center hvr-underline-from-centernew", href: "javascript:void(0);" 
        str += content_tag(:input, nil, :type => 'submit', :value => title, :class => "mdl-button mdl-js-button mdl-button--raised mdl-button--colored mdl-js-ripple-effect mdl-color--light-blue-600 f-right m-r-35") 
        str
      # end
  end

  def custom_button_tag_without_hide(title)
    content_tag :div, class: "mdl-cell--4-col mdl-cell--4-col-tablet mdl-cell--4-col-phone m-8" do
      content_tag :div, class: "moreBtn collapseminus" do
        str = content_tag(:input, nil, :type => 'submit', :value => title, :class => "mdl-button mdl-js-button mdl-button--raised mdl-button--colored mdl-js-ripple-effect mdl-color--light-blue-600 f-right m-r-35") 
        str
      end
    end
  end

  def custom_basic_text_field_tag(name, title, params, *args)
    params = params.to_s
    params1 = params.delete('\\{}"')#params.gsub(/[^0-9a-zA-Z]/, " ")
    if params["selected"].present?
      params = params1.slice!(0..10)
    elsif params["invitee_status"].present? or params["visible_status"].present?
      params = params1.slice!(0..15)
    elsif params["login_status"].present? or params["company_name"].present?
      params = params1.slice!(0..13)
    elsif params["designation"].present?
      params = params1.slice!(0..12)
    else
      params = params1.slice!(0..8)
    end
    str = content_tag(:input, nil, :type => 'text', :name => name, :value => params1, :class => "mdl-textfield__input")
    str += content_tag :label, title, class: "mdl-textfield__label"
    str
  end

  def custom_basic_button_tag(title)
    content_tag :div, class: "mdl-cell--2-col mdl-cell--1-col-tablet mdl-cell--2-col-phone m-10" do
      content_tag(:input, nil, :type => 'submit', :value => title, :class => "mdl-button mdl-js-button mdl-button--raised mdl-button--colored mdl-js-ripple-effect mdl-color--light-blue-600") 
    end  
  end  


  def custom_advance_search_link_tag(label)
    content_tag :div, class: "mdl-cell--4-col mdl-cell--2-col-tablet mdl-cell--2-col-phone m-l-15 moreBtn mdl-typography--text-right" do
      content_tag :a, "Search", class: "adminClick hvr-underline-from-center", href: "javascript:void(0);"
    end
  end
  
  #show page edit link
  def show_edit_link(params)
    if !(current_user.has_role? :moderator) and !(current_user.has_role? :client_response_manager)
      if params[:controller] == "admin/mobile_applications" and (params[:client_id].present?)
        url = "/admin/clients/#{params[:client_id]}/mobile_applications/#{params[:id]}/edit"
      elsif params[:controller] == "admin/mobile_applications" and (params[:event_id].present?)
        url = "/admin/clients/#{@event.client_id}/mobile_applications/#{@event.mobile_application_id}/edit" 
        #"/admin/events/#{params[:event_id]}/mobile_applications/#{params[:id]}/edit?type=event_edit"
      elsif params[:controller] == "admin/events" and @client.present?
        url = "/admin/clients/#{params[:client_id]}/events/#{params[:id]}/edit"
      elsif params[:controller] == "admin/winners"
        url = "/admin/events/#{params[:event_id]}/awards/#{params[:award_id]}/#{params[:controller].split("/").second}/#{params[:id]}/edit"
      elsif params[:controller] == "admin/licensees"
        url = "/admin/licensees/#{params[:id]}/edit"
      elsif params[:controller] == "admin/themes" and params[:event_id].blank?
        url = "/admin/themes/#{params[:id]}/edit"  
      else
        url = "/admin/events/#{params[:event_id]}/#{params[:controller].split("/").second}/#{params[:id]}/edit"
      end  
      content_tag :p , class: "m-t-20 headingInfo" do 
        content_tag :a , class: "editLink", href: url do
          content_tag :i , class: "material-icons" do
            "edit"
          end  
        end
      end
    end      
  end

  def show_edit_link_without_event(params)
    content_tag :p , class: "m-t-20 headingInfo" do 
      content_tag :a , class: "editLink", href: "/admin/#{params[:event_id]}/#{params[:controller].split("/").second}/#{params[:id]}/edit" do
        content_tag :i , class: "material-icons" do
          "edit"
        end  
      end
    end    
  end

  def edit_link(params, id)
    if params[:controller] == "admin/abouts"
      content_tag :a , class: "mdl-menu__item mdl-js-ripple-effect", href: "/admin/events/#{@event.id}/abouts/new?edit=true" , class: "mdl-menu__item"  do
        "Edit"
      end
    elsif params[:controller] == "admin/invitee_structures" and @event.present? and @groupings.present?
      content_tag :a , class: "mdl-menu__item mdl-js-ripple-effect", href: "/admin/events/#{params[:event_id]}/groupings/#{id}/edit" , class: "mdl-menu__item"  do
        "Edit"
      end
    else
      if params[:from] == "microsites"
        content_tag :a , class: "mdl-menu__item mdl-js-ripple-effect", href: "/admin/events/#{params[:event_id]}/#{params[:controller].split("/").second}/#{id}/edit?from=microsites" , class: "mdl-menu__item"  do
          "Edit"
        end
      else 
        content_tag :a , class: "mdl-menu__item mdl-js-ripple-effect", href: "/admin/events/#{params[:event_id]}/#{params[:controller].split("/").second}/#{id}/edit" , class: "mdl-menu__item"  do
          "Edit"
        end
      end
    end    
  end  

  def send_mail_to_invitee(params,id)
    content_tag :a , class: "mdl-menu__item mdl-js-ripple-effect", href: "/admin/events/#{params[:event_id]}/invitees/#{id}?send_mail=true" , class: "mdl-menu__item send-password-btn"  do
      "Send Password"
    end
  end

  def delete_link1(params, id)
    content_tag :a , class: "mdl-menu__item mdl-js-ripple-effect", href: "/admin/events/#{params[:event_id]}/groupings/#{id}?group=all" , 'data-method' => :delete ,class: "mdl-menu__item", data: { confirm: 'Are you sure?' } do
      "Delete"  
    end
  end

  def delete_link(params, id)
    if params[:controller] == "admin/invitee_structures" and @event.present? and @groupings.present?
      content_tag :a , class: "mdl-menu__item mdl-js-ripple-effect", href: "/admin/events/#{params[:event_id]}/groupings/#{id}" , 'data-method' => :delete ,class: "mdl-menu__item", data: { confirm: 'Are you sure?' } do
        "Delete Group"  
      end
    else
      if params[:from] == "microsites"
        content_tag :a , class: "mdl-menu__item mdl-js-ripple-effect", href: "/admin/events/#{params[:event_id]}/#{params[:controller].split("/").second}/#{id}?from=microsites" , 'data-method' => :delete ,class: "mdl-menu__item", data: { confirm: 'Are you sure?' } do
          "Delete"
        end
      else
        content_tag :a , class: "mdl-menu__item mdl-js-ripple-effect", href: "/admin/events/#{params[:event_id]}/#{params[:controller].split("/").second}/#{id}" , 'data-method' => :delete ,class: "mdl-menu__item", data: { confirm: 'Are you sure?' } do
          "Delete"
        end
      end
    end
  end

  def delete_link1(params, id)
    content_tag :a , class: "mdl-menu__item mdl-js-ripple-effect", href: "/admin/events/#{params[:event_id]}/groupings/#{id}?group=all" , 'data-method' => :delete ,class: "mdl-menu__item", data: { confirm: 'Are you sure?' } do
      "Delete"  
    end
  end

  def delete_link_all(params, id)
    content_tag :a , class: "mdl-menu__item mdl-js-ripple-effect", href: "/admin/events/#{params[:event_id]}/groupings/#{id}?invitee_data=all" , 'data-method' => :delete ,class: "mdl-menu__item", data: { confirm: 'Are you sure?' } do
      "Delete Record"  
    end
  end

  def manage_panel_link(params, id)
    content_tag :a , class: "mdl-menu__item mdl-js-ripple-effect", href: "/admin/events/#{params[:event_id]}/panels",class: "mdl-menu__item" do
      "Manage Panel"
    end
  end  

  def show_link(params, id, value)
    feature = (params[:controller] == "admin/sequences" ? params[:feature_type] : params[:controller].split("/").second )
    content_tag :a , class: "collection-item" , href: "/admin/events/#{params[:event_id]}/#{feature}/#{id}" do
      value
    end
  end

  def more_vert_button(id)
    content_tag :button , class: "mdl-button mdl-js-button mdl-button--icon prevent_button", id: "demo-menu-lower-right#{id}" do
      content_tag :i , class: "material-icons" do
        "more_vert"
      end  
    end  
  end  

  def more_vert_button1(id)
    content_tag :link_to , class: "mdl-button mdl-js-button mdl-button--icon prevent_button", id: "demo-menu-lower-right#{id}" do
      content_tag :i , class: "material-icons" do
        "more_vert"
      end  
    end  
  end  

  def basic_search_value(params)
    (params[:adv_search] == "true") ? "" : params[:search]
  end

  def adv_search_value(params,name)
    params[:search].present? ? params[:search][name] : ""
  end

  def calculate_rating(speaker,type)   
    if type == "agenda"
      speaker.ratings.pluck(:rating).sum / speaker.ratings.count rescue 0
    else
      speaker.ratings.pluck(:rating).sum / speaker.ratings.count.to_f rescue 0
    end
  end

  def event_speakers_list(event_id)
    list_of_speakers = Speaker.where("event_id =?", event_id) if event_id.present?
  end

  def correct_user_polls_for_percentile(poll,option)
    percentage = 0
    user_polls = poll.user_polls if poll.user_polls.present?
    # total = user_polls.pluck(:answer).join(",").split(",").count
    if user_polls.present?
      total = user_polls.count
      count = 0
      user_polls.each do |ans|
        count = count + 1 if ans.answer.downcase.split(',').include?(option.downcase)
      end
      percentage = (count.to_f/total) * 100 rescue 0
    end
    return "#{percentage.round} %"
  end

  def correct_user_polls_for_total_count(poll,option)
    user_polls = poll.user_polls if poll.user_polls.present?
    if user_polls.present?
      count = 0
      user_polls.each do |ans|
        count = count + 1 if ans.answer.downcase.split(',').include?(option.downcase)
      end
    end
    return count
  end

  def correct_user_quizzes_for_percentile(quiz,option)
    percentage = 0
    user_quizzes = quiz.user_quizzes if quiz.user_quizzes.present?
    if user_quizzes.present?
      total = user_quizzes.count
      count = 0
      user_quizzes.each do |ans|
        count = count + 1 if quiz.attributes.key(ans.answer).to_s == option
      end
      percentage = (count.to_f/total) * 100 rescue 0
    end
    return "#{percentage.round} %"
  end

  def correct_user_quizzes_for_percentile_for_wall(quiz,option) 
     percentage = 0
     user_quizzes = quiz.user_quizzes if quiz.user_quizzes.present?
     if user_quizzes.present?
       total = user_quizzes.count
       count = 0
       user_quizzes.each do |ans|
         count = count + 1 if quiz.attributes.key(ans.answer).to_s == option
       end
       percentage = (count.to_f/total) * 100 rescue 0
     end
     return "#{percentage.round}" 
  end

  def correct_user_quizzes_for_total_count(quiz,option)
    user_quizzes = quiz.user_quizzes if quiz.user_quizzes.present?
    if user_quizzes.present?
      count = 0
      user_quizzes.each do |ans|
        count = count + 1 if ans.answer.split(',').include?(quiz.attributes[option])
      end
    end
    return count
  end

  

  def get_current_user_role
    current_user.has_role? :licensee_admin or current_user.has_role? :client_admin or current_user.has_role? :event_admin
  end

  def get_role_listing_on_role_based(user, source)
    roles = Role.joins(:users).where('roles.resource_type = ? and resource_id = ? and users.id = ?', "#{source.class.name}", source.id, user.id).pluck(:name)
    if roles.include? 'licensee_admin' or roles.include? 'client_admin' or user.has_role? 'licensee_admin' or user.has_role? 'client_admin'
      [['Event Admin', 'event_admin'], ['Module Admin', 'moderator']]
    elsif roles.include? 'event_admin' or user.has_role? 'event_admin'
      [['Module Admin', 'moderator']]
    elsif roles.include? 'moderator'
      []
    end
  end

  def get_status_class(event)
    status_class = ""
    if event.status == "published" or event.status == "approved"
      status_class = "stausactive"
    elsif event.status == "pending"
      status_class = "statuspending"
    else 
      status_class = "statusreject"
    end
    status_class  
  end
  
  def index_nodata_message(value)
    controller_lists = ["admin/conversations", "admin/qnas"]
    controller_lists.include?(params["controller"]) ? "There are no #{value.humanize.titleize}." : "There are no #{value.humanize.titleize}. Click here to"
  end

  def get_search_data(value)
    "We could not find any #{value} for your selected filters."
  end

  def show_card(value)
    value = "galleries" if value == "images"
    @event.event_features.pluck(:name).include?(value)
  end

  def show_card_except_event_features(value)
    value = "galleries" if value == "images"
    @event.event_features.pluck(:name).exclude?(value)
  end

  def show_card_microsite(value)
    #value = "galleries" if value == "images"
    @event.microsite.microsite_features.pluck(:name).include?(value)
  end

  def show_card_except_microsite_features(value)
    # value = "galleries" if value == "images"
    @event.microsite.microsite_features.pluck(:name).exclude?(value)
  end
  
  def gallery_folder_enable(event)
    event.event_features.where("image_setting = ? and name = ?", "yes", "galleries").present?
  end

  def gallery_folder_setting_not_saved(event)
    event.event_features.where("name = ?", "galleries").present? and event.event_features.where("name = ?", "galleries").last.image_setting.blank?
  end
  
  def find_option_percentage(feedback,option)
    percentage = 0
    user_feedbacks = feedback.user_feedbacks if feedback.user_feedbacks.present?
    if user_feedbacks.present?
      total = user_feedbacks.count
      count = 0
      user_feedbacks.each do |ans|
        count = count + 1 if ans.answer.split(",").include?(option)
      end
      percentage = (count.to_f/total) * 100 rescue 0
    end
    return "#{percentage.to_i}%"
  end

  def correct_user_feedback_for_total_count(feedback,option)
    user_feedbacks = feedback.user_feedbacks if feedback.user_feedbacks.present?
    if user_feedbacks.present?
      count = 0
      user_feedbacks.each do |ans|
        count = count + 1 if ans.answer.split(',').include?(option)
      end
    end
    return count
  end

  def dashboard_to_page_redirect_url(count,card)
    if count == 1
      admin_clients_path(:feature => card)
    else
      admin_clients_path(:feature => card)
    end
  end

  def check_curent_user_role(role_type,client_ids,session_role_name)
    module_access = false
    if role_type == "client"
      module_access = current_user.has_role_without_event("licensee_admin", client_ids,session[:current_user_role])#current_user.has_role? :licensee_admin
    elsif role_type == "event"
      module_access = (current_user.has_role_without_event("licensee_admin", client_ids,session[:current_user_role]) or current_user.has_role_without_event("client_admin", client_ids,session[:current_user_role]))#current_user.has_any_role?(:licensee_admin, :client_admin)
    elsif role_type == "mobile_application"
      module_access = (current_user.has_role_without_event("licensee_admin", client_ids,session[:current_user_role]) or current_user.has_role_without_event("client_admin", client_ids,session[:current_user_role]))#current_user.has_any_role?(:licensee_admin, :client_admin)
    end
    module_access    
  end

  def select_login_at
    @mobile_application.login_at == "Yes" ? "none" : "block"
  end

  def get_notify_to_dispplay_style
    (@notification.notify_type == "Group") ? "block" : "none" 
  end

  def get_mobile_app_redirect_url(mob_application,page)
    if mob_application.events.length == 1
      if page == "show"
        admin_event_mobile_application_path(mob_application.events.first.id, mob_application.id) 
      elsif page == "edit" 
        edit_admin_event_mobile_application_path(mob_application.events.first.id, mob_application.id)
      end 
    else
      admin_client_events_path(:client_id => mob_application.client_id, :feature => "mobile_application", :mobile_application_id => mob_application.id, :redirect_page => page)
    end
  end

  def set_highlight_class(name)
    get_obj = self.object ||  self.options[:parent_builder].object
    unless get_obj.new_record? || get_obj.new_record?
      (get_obj.attribute_present? name) ? "has-success" : "has-warning"
    end
  end

  def get_last_user_registration_field_index(obj)
    a = []
    obj.attributes.except('id', 'created_at', 'updated_at', 'event_id', 'custom_css', 'custom_js', 'custom_source_code').each_with_index do |t, index|
      index = index + 1
      a << ((t[1].present? and t[1]['label'].present? or t[1].present? and t[1]['option_type'].present?) ? index : nil)
    end
    a = a.compact
    index = a.last
    index
  end
end

  def custom_text_field_tag_user(name,title, params,*args)
    str = ''
    content_tag :div, class: "mdl-cell--12-col mdl-cell--12-col-tablet m-8" do
      content_tag :div, class: "bs-component" do
        content_tag :div, class: "form-group" do
          str = content_tag :label, title, class: "col-lg-4 control-label"
          str += content_tag :div, class: "col-lg-7" do
            content_tag(:input, nil, :type => 'text', :name => name, :value => params, :class => "mdl-textfield__input", :id => (args[0].present?) ? args[0][:id] : '')
          end
          str 
        end 
      end
    end
  end

  def custom_text_field_tag_import(params,*args)
    str = ''
    content_tag :div, class: "mdl-cell--12-col mdl-cell--12-col-tablet m-8" do
      content_tag :div, class: "bs-component" do
        content_tag :div, class: "form-group" do
          str = content_tag :label, content_tag(:input, nil, :type => 'text')
          str 
        end 
      end
    end
  end


  def custom_text_field_tag_user(name,title, params, options = {} ,*args)
    str = ''
    content_tag :div, class: "mdl-cell--12-col mdl-cell--12-col-tablet m-8" do
      content_tag :div, class: "bs-component" do
        content_tag :div, class: "form-group" do
          str = content_tag :label, title, class: "col-lg-4 control-label"
          str += content_tag :div, class: "#{options[:search_button].present? ? "col-lg-6" : "col-lg-7"}" do
            role_class = options[:role_name].present? ? "roleName" : ""
            content_tag(:input, nil, :type => 'text', :name => name, :value => params, :class => "form-control #{role_class}" , :id => (options[:id].present?) ? options[:id] : '')
          end
          if options[:search_button].present?
            str += content_tag :div, class: "col-lg-2" do
              content_tag(:input, nil, :type => 'submit', :value => "Go", :class => "mdl-button mdl-js-button mdl-button--raised mdl-button--colored mdl-js-ripple-effect mdl-color--light-blue-600") 
              # content_tag :div, class: " searchUser moreBtn collapseminus " do
              # end
            end
          end  
          str 
        end 
      end
    end
  end 
  def custom_button_tag_without_hide_user(title, id=nil)
    content_tag :div, class: "mdl-cell--12-col mdl-cell--12-col-tablet mdl-cell--12-col-phone m-8" do
      content_tag :div, class: " searchUser moreBtn collapseminus " do
        str = content_tag(:input, nil, :type => 'submit', :value => title, :class => "mdl-button mdl-js-button mdl-button--raised mdl-button--colored mdl-js-ripple-effect mdl-color--light-blue-600 m-t-10", :id => id[:id]) 
        str
      end
    end
  end

  def custom_message_display(menu)
    msg_desplay = (menu.status == "active") ? "none" : ""
    msg_desplay
  end   

  def set_image_uploader_color(value,action)
    if action != "new"
      if value.nil?
        "has-warning"
      else
        "has-success"
      end
    end
  end

  def set_end_agenda_time_hour(hour)
    if hour.strftime("%H") == "00"
      return nil
    else
      return hour.strftime("%I")
    end if hour.present?
  end

  def set_end_agenda_time_minute(minute)
    if minute.strftime("%M") == "00"
      return nil
    else
      return minute.strftime("%M")
    end if minute.present?
  end

  def get_login_at(event,object)
    if object.errors.present?
      (params[:event][:login_at] == "After Splash") ? "" : "none" 
    else
      (event.login_at == 'Before Interaction'or event.login_at == 'After Highlight') ? "none" : "" if event.present?
    end
  end

  def set_end_agenda_time_am(am)
    if am.strftime("%p") != "AM" or am.strftime("%p") != "PM" and (am.strftime("%H:%M") == "00:00")
      return nil
    else
      return am.strftime("%p")
    end if am.present?
  end

  def get_highlight_class1(object)
    if (object.login_background_color.present?)
      "has-success"
    elsif (object.login_background.blank? and object.login_background_color.blank?)
      "has-warning"
    elsif (object.login_background.blank? and object.login_background_color.present?)
      ""  
    end if params[:action] != "new"
  end

  def get_highlight_class(object)
    if (object.login_background.blank? and object.login_background_color.blank?)
      ""
    elsif object.login_background.present?
      "has-success"
    elsif (object.login_background.present? and object.login_background_color.blank?  )
      ""
    end if params[:action] != "new"
  end  
  def get_user_poll_percentage(option,poll)
    count = 0
    percentage = 0.0
    length = poll.user_polls.length
    answers = poll.user_polls.pluck(:answer)
    # answers.each do |answer|
    #   count = count + 1 if answer.downcase == option
    # end
    answers.each do |answer|
      count = count + 1 if answer.split(',').include?(option)
    end
    percentage = (count/length.to_f) * 100 rescue 0 if length > 0
    percentage.round
  end

  def get_menu_icon_display(event,object)
    if event.default_feature_icon == "owns"
      "yes"
    elsif event.default_feature_icon != "owns" and ["custom_page1s","custom_page2s","custom_page3s","custom_page4s","custom_page5s","custom_page6s","custom_page7s","custom_page8s","custom_page9s","custom_page10s"].include?(object.name)
      "yes"
    else
      "no"
    end
  end

  def get_publish_event_message
    @mobile_application.store_info.present? ? "Do you want to Add this Event in the Published App?" : "Are you sure, you want to Publish this." rescue ""
  end

  def is_number? string
    true if Float(string) rescue false
  end

  def get_notification_type_group_array(event)
    # action_based = {'agendas' => [['Agenda Rating', 'agendas']], 'favorites' => [['Agenda Favorite', 'agendas'], ['Speaker Favorite', 'speakers'], ['Invitee Favorite', 'invitees'], ['Sponsor Favorite', 'sponsors'], ['Exhibitors Favorite', 'exhibitors']]}
    # logic_based = {'polls' => [['Polls Taken', 'polls']], 'feedbacks' => [['Feedback Submitted', 'feedbacks']], 'quizzes' => [['Quiz Answered', 'quizzes']], 'qnas' => [['Question Asked', 'qnas']], 'qr_code' => [['QR Code Scanned', 'qr_code']]}
    # destination_based = {'event_highlights' => [['Event Highlight', 'event_highlights']], 'quizzes' => [['Quiz', 'quizzes']], 'qnas' => [['Q&A', 'qnas']], 'speakers' => [['Speaker', 'speakers']], 'invitees' => [['Invitee', 'invitees']], 'my_profile' => [['My Profile', 'my_profile']], 'feedbacks' => [['Feedback', 'feedbacks']], 'agendas' => [['Agenda', 'agendas']], 'polls' => [['Poll', 'polls']], 'leaderboard' => [['Leaderboard', 'leaderboard']], 'faqs' => [['FAQ', 'faqs']], 'abouts' => [['About', 'abouts']], 'conversations' => [['Conversation', 'conversations']], 'e_kits' => [['E-Kit', 'e_kits']], 'awards' => [['Award', 'awards']], 'contacts' => [['Contact', 'contacts']], 'sponsors' => [['Sponsors', 'sponsors']], 'galleries' => [['Gallery', 'galleries']], 'emergency_exits' => [['Emergency Exit', 'emergency_exits']], 'notes' => [['Note', 'notes']], 'venue' => [['Venue', 'venue']], 'custom_page1s' => [['Custom Page1', 'custom_page1s']], 'custom_page2s' => [['Custom Page2', 'custom_page2s']], 'custom_page3s' => [['Custom Page3', 'custom_page3s']], 'custom_page4s' => [['Custom Page4', 'custom_page4s']], 'custom_page5s' => [['Custom Page5', 'custom_page5s']]}
    #action_based = {'agendas' => [['Agenda Rating', 'Agenda Rating']], 'speakers' => [['Speaker Rating', 'Speaker Rating']], 'favourites' => [['Agenda Favorite', 'Agenda Favorite'], ['Speaker Favorite', 'Speaker Favorite'], ['Invitee Favorite', 'Invitee Favorite'], ['Sponsor Favorite', 'Sponsor Favorite'], ['Exhibitors Favorite', 'Exhibitors Favorite']]}
    #logic_based = {'polls' => [['Polls Taken', 'Polls Taken']], 'feedbacks' => [['Feedback Submitted', 'Feedback Submitted']], 'quizzes' => [['Quiz Answered', 'Quiz Answered']], 'qnas' => [['Question Asked', 'Question Asked']], 'qr_code' => [['QR Code Scanned', 'QR Code Scanned']]}
    # destination_based = {'event_highlights' => [['Event Highlight', 'Event Highlight']], 'quizzes' => [['Quiz', 'Quiz']], 'qnas' => [['Q&A', 'Q&A']], 'Q&A' => [['Speaker', 'Speaker']], 'invitees' => [['Invitee', 'Invitee']], 'my_profile' => [['My Profile', 'Profile']], 'feedbacks' => [['Feedback', 'Feedback']], 'agendas' => [['Agenda', 'Agenda']], 'polls' => [['Poll', 'Poll']], 'leaderboard' => [['Leaderboard', 'Leaderboard']], 'faqs' => [['FAQ', 'FAQ']], 'abouts' => [['About', 'About']], 'conversations' => [['Conversation', 'Conversation']], 'e_kits' => [['E-Kit', 'E-Kit']], 'awards' => [['Award', 'Award']], 'contacts' => [['Contact', 'Contact']], 'sponsors' => [['Sponsors', 'Sponsors']], 'galleries' => [['Gallery', 'Gallery']], 'emergency_exits' => [['Emergency Exit', 'Emergency Exit']], 'notes' => [['Note', 'Note']], 'venue' => [['Venue', 'Venue']], 'custom_page1s' => [['Custom Page1', 'Custom Page1']], 'custom_page2s' => [['Custom Page2', 'Custom Page2']], 'custom_page3s' => [['Custom Page3', 'Custom Page3']], 'custom_page4s' => [['Custom Page4', 'Custom Page4']], 'custom_page5s' => [['Custom Page5', 'Custom Page5']]}
    destination_based = {'event_highlights' => ['Event Highlights', 'Event Highlight'], 'quizzes' => ['Quiz', 'Quiz'], 'qnas' => ['Q&A', 'Q&A'], 'speakers' => ['Speakers', 'Speaker'], 'invitees' => ['Invitees', 'Invitee'], 'my_profile' => ['My Profile', 'Profile'], 'feedbacks' => ['Feedback', 'Feedback'], 'agendas' => ['Agenda', 'Agenda'], 'polls' => ['Polls', 'Poll'], 'leaderboard' => ['Leaderboard', 'Leaderboard'], 'faqs' => ['FAQ', 'FAQ'], 'abouts' => ['About', 'About'], 'conversations' => ['Conversations', 'Conversation'], 'e_kits' => ['E-Kit', 'E-Kit'], 'awards' => ['Awards', 'Award'], 'contacts' => ['Contact', 'Contact'], 'sponsors' => ['Sponsors', 'Sponsor'], 'galleries' => ['Gallery', 'Gallery'], 'emergency_exits' => ['Emergency Exit', 'Emergency Exit'], 'exhibitors' => ['Exhibitors', 'Exhibitor'], 'my_travels' => ['My Travel', 'My Travel'], 'notes' => ['Notes', 'Note'], 'venue' => ['Venue', 'Venue'], 'custom_page1s' => ['Custom Page1', 'Custom Page1'], 'custom_page2s' => ['Custom Page2', 'Custom Page2'], 'custom_page3s' => ['Custom Page3', 'Custom Page3'], 'custom_page4s' => ['Custom Page4', 'Custom Page4'], 'custom_page5s' => ['Custom Page5', 'Custom Page5'], 'custom_page6s' => ['Custom Page6', 'Custom Page6'], 'custom_page7s' => ['Custom Page7', 'Custom Page7'], 'custom_page8s' => ['Custom Page8', 'Custom Page8'], 'custom_page9s' => ['Custom Page9', 'Custom Page9'], 'custom_page10s' => ['Custom Page10', 'Custom Page10'], 'qr_code' => ['QR code', 'QR code'], 'favourites' => ['My Favorites', 'My Favorite']}
    # all_arr = []
    # action_arr = []
    # logic_arr = []
    dest_arr = []
    event.event_features.not_hidden_icon.each do |feature|
      #action_arr += action_based[feature.name] if action_based[feature.name].present?
      #logic_arr += logic_based[feature.name] if logic_based[feature.name].present?
      dest_arr << destination_based[feature.name] if destination_based[feature.name].present?
    end
    #all_arr = [['Group based', ['Group Notification']], ['Action based', action_arr], ['Logic based', logic_arr], ['Destination based', dest_arr]]
    # all_arr = [['Group based', ['Group Notification']], ['Destination based', dest_arr]]
    # all_arr = [['Destination pages', dest_arr]]
    dest_arr = dest_arr.sort_by{|a| a[0]} if dest_arr.present?
    dest_arr
  end

  def store_url_for(params)
    url = url_for(params)
    if url.include?("//?")
      url.sub("//?", "/store?")
    else
      url
    end
  end

  def datetime_with_adjusted_offset(datetime, offset)
    datetime + offset.to_i.seconds
  end

  def datetime_with_display_timezone(datetime, display_timezone)
    "#{datetime.strftime('%b %d at %l:%M %P')} (#{display_timezone})"
  end

  def datetime_with_adjusted_offset_and_display_timezone(datetime, offset, display_timezone)
    time_with_offset = datetime_with_adjusted_offset(datetime, offset)
    datetime_with_display_timezone(time_with_offset, display_timezone)
  end

  def get_notification_icon_by_action(notification)
    hsh = {"About" => "about", "Agenda" => "agenda", "Speaker" => "speakers", "FAQ" => "faq", "Gallery" => "galler_1y", "Feedback" => "feedback", "E-Kit" => "e-kit","Conversation" => "conversations","Poll" => "polls_1","Award" => "awards_2","Invitee" => "invitees","Q&A" => "Q&A", "Note" => "note", "Contact" => "contact_us", "Event Highlight" => "event_highlights","Sponsor" => "sponsor", "Sponsors" => "sponsor", "Profile" => "my_profile", "QR code" => "qr_code","Quiz" => "polls","My Favorite" => "myfavourite","Exhibitor" => "Exhibitor-breadcumb",'Venue' => "venue", 'Leaderboard' => "Leaderboard", "Custom Page1" => "custom", "Custom Page2" => "custom", "Custom Page3" => "custom","Custom Page4" => "custom","Custom Page5" => "custom", "Custom Page6" => "custom", "Custom Page7" => "custom", "Custom Page8" => "custom","Custom Page9" => "custom","Custom Page10" => "custom", "chats" => "chat", "My Travel" => "travel","social_sharings" => "social_sharing"}
    if hsh[notification.action].present?
      "/assets/coloured_icons/#{hsh[notification.action]}.png"
    elsif notification.action.blank? or notification.action.to_s.downcase == "home page"
      "/assets/coloured_icons/notification.png"
    else
      ""
    end
  end

  def get_visiblity_column_name(model)
    case model
      when 'EventFeature'
        "show_event_feature"
      when 'Speaker'
        "show_speaker_feature"
      when 'Poll'
        "show_poll_feature"
      when 'Quiz'
        "show_quiz_feature"
      when 'FeedbackForm'
        "show_feedback_feature"
      when 'UserFeedback'  
        "show_feedback_feature"
      when 'EKit' 
        "show_e_kit_feature"
      when "Agenda"
        "show_agenda_feature"
    end 
  end
#end