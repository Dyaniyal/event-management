class CustomFormBuilder < ActionView::Helpers::FormBuilder
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::CaptureHelper
  include ActionView::Helpers::AssetTagHelper


  def custom_radio_button_menu_regis(method, tag_value,options = {}, *args)
    @template.content_tag :label, class: "col-lg-4 mdl-radio mdl-js-radio mdl-js-ripple-effect", for: "#{args[0].values[0]}" do
     str = @template.radio_button(@object_name, method, tag_value, :checked => args.first[:default_checked], id: "#{args[0].values[0]}", class: "#{args[0][:class].present? ? "#{args[0][:class]} mdl-radio__button": "mdl-radio__button"}")
      str += label(options)   
    end
  end
  
  def custom_radio_button1(method, tag_value, options = {})
    @template.radio_button(@object_name, method, tag_value, objectify_options(options)) + 
    @template.label(@object_name, options[:label], objectify_options(options))
  end
           
  
  def custom_radio_button(method, tag_value, options = {}, *args)
    @template.content_tag :label, class: "mdl-radio mdl-js-radio mdl-js-ripple-effect", for: "#{args[0].values[0]}"  do
     str = @template.radio_button(@object_name, method, tag_value, id: "#{args[0].values[0]}", class: "mdl-radio__button")
      str += label(options)
    end
  end

  def custom_radio_button_for_user_registration(method, tag_value, options = {}, *args)
    @template.content_tag :label, class: "mdl-radio mdl-js-radio mdl-js-ripple-effect radio_font", for: "#{args[0].values[0]}"  do
     str = @template.radio_button(@object_name, method, tag_value, id: "#{args[0].values[0]}", class: "mdl-radio__button")
      str += label(options,options)
    end
  end

  def custom_radio_button_edm(method, tag_value, options = {}, *args)
    @template.content_tag :label, class: "mdl-radio mdl-js-radio mdl-js-ripple-effect", for: "#{args[0].values[0]}", :style => "#{args[0][:width]}" do
     str = @template.radio_button(@object_name, method, tag_value, id: "#{args[0].values[0]}", class: "mdl-radio__button")
      str += label(options)   
    end
  end

  def custom_radio_button_menu(method, tag_value,options = {}, *args)
    @template.content_tag :label, class: "mdl-radio mdl-js-radio mdl-js-ripple-effect", for: "#{args[0].values[0]}" do
     str = @template.radio_button(@object_name, method, tag_value, :checked => args.first[:default_checked], id: "#{args[0].values[0]}", class: "#{args[0][:class].present? ? "#{args[0][:class]} mdl-radio__button": "mdl-radio__button"}")
      str += label(options)   
    end
  end

  def custom_radio_button2(method, tag_value, options = {}, *args)
    @template.content_tag :label, class: "mdl-radio mdl-js-radio mdl-js-ripple-effect", for: "#{args[0].values[0]}" do
     str = @template.radio_button(@object_name, method, tag_value, :checked => "#{(tag_value == "create your own theme" ? "checked" : false)}", id: "#{args[0].values[0]}", class: "mdl-radio__button")
      str += label(options)   
    end
  end

  def custom_radio_button_for_marketing_app(method, tag_value, options = {}, *args)
    @template.content_tag :label, class: "mdl-radio mdl-js-radio mdl-js-ripple-effect", for: "#{args[0].values[0]}" do
     str = @template.radio_button(@object_name, method, tag_value, :checked => "#{(args[0].values[1]== "true" ? "checked" : false)}",:disabled => "#{args[0].values[1] == "true" ? true : false}", id: "#{args[0].values[0]}", class: "mdl-radio__button")
      str += label(options)   
    end
  end

  def old_custom_text_field(name, title, *args)
    args[0] ||= {}
    args.first[:col] ||= "8"
    @template.content_tag :div, class: "mdl-cell--#{args.first[:col]}-col mdl-cell--#{args.first[:col]}-col-tablet ml-color--shades-white m-8" do
      (@template.content_tag :div, class: "mdl-textfield mdl-js-textfield mdl-textfield--floating-label is-upgraded" do
        # if title == "Theme Name"
        #   args.first[:class] ||= "mdl-textfield__input"
        # elsif title == "Event Start Time" || title == "Event End Time"
        #   args.first[:class] = "mdl-textfield__input time_txt"
        # else
        if args.first[:class].blank?
          args.first[:class] = "mdl-textfield__input"
        else
          args.first[:class] = "mdl-textfield__input #{args.first[:class]}"
        end
        # end
        str = text_field(name, args.first)
        str += label(title, options[:label], class: 'mdl-textfield__label')
        str
      end)
    end
  end

  def custom_text_field_for_registration(name, title, *args)
    args[0] ||= {}
    args.first[:col] ||= "12"
    @template.content_tag :div, class: "mdl-cell--#{args.first[:col]}-col mdl-cell--#{args.first[:col]}-col-tablet ml-color--shades-white m-8" do
      @template.content_tag :div, class: "bs-component", :style => "display: #{args[0][:message_display].present? ? args[0][:message_display] : ""}; font-family: #{args[0]["font_style"].present? ? args[0]["font_style"] : ""};"do
        @template.content_tag :div, class: "form-group #{args[0][:admin_theme].present? ? args[0][:admin_theme] : "" rescue ""} #{args[0]["background"] == "false" ? "" : (args[0][:route].present? ? set_highlight_class1(name,args[0][:field_name]) : set_highlight_class(name))}" do
          str = @template.label("", "#{title}", class: "col-lg-4 control-label", id: "#{name}_label")
          str += @template.content_tag :div, class: "col-lg-7" do
            @template.content_tag :span, class: "append-icon right" do
              @template.content_tag :i, :class => "fa fa-gear"
            end
            if args.first[:class].blank?
              args.first[:class] = "form-control"
            else
              args.first[:class] = "form-control #{args.first[:class]}"
            end
            text_field(name, args.first)
          end
          str += @template.content_tag :span, class: "col-lg-1" do
            @template.link_to(" ? " ,"/whats_this/#{args.first[:view_popup][:image_path] rescue ""}", rel: "#{args.first[:view_popup][:rel] rescue "#{name}"}", title: "#{args.first[:view_popup][:title] rescue ""}", :class =>"fancybox whatsImg") if args.first[:view_popup].present?
          end
          str
        end
      end      
    end
  end


  
  
  # def custom_file_browser_field(name, title, id,*args)
  #   @template.content_tag :div, class: "mdl-cell--6-col mdl-cell--4-col-tablet ml-color--shades-white m-8" do
  #     str = label(title, options[:label])
  #     str += file_field(name, *args)
  #   end  
  # end

  def custom_file_browser_field(name, title, id,*args)
    args[0] ||= {}
    args.first[:col] ||= "8"
    @template.content_tag :div, class: "mdl-cell--#{args.first[:col]}-col mdl-cell--#{args.first[:col]}-col-tablet ml-color--shades-white m-8" do
      @template.content_tag :div, class: "mdl-grid mdl-grid--no-spacing" do
        div = @template.content_tag :div, class: "mdl-cell--6-col mdl-cell--6-col-tablet ekitpage" do
          @template.content_tag :div, class: "mdl-textfield mdl-js-textfield mdl-textfield--floating-label disableinput" do
            # str = file_field(name, id: id, class: "upload")
            str = label(title, options[:label])
          end 
        end
        div += @template.content_tag :div, class: "mdl-cell--1-col mdl-cell--1-col-tablet fileUpload thems-imgupload" do
          str = file_field(name, id: id[:id], class: "upload")
        end
        div += @template.content_tag :div, class: "mdl-cell--5-col mdl-cell--5-col-tablet" do
          @template.label("", "", class: "mdl-textfield mdl-js-textfield mdl-textfield--floating-label file_name", id: "1#{id[:id]}"  )
        end
      end
    end 
  end  
  

  def old_custom_text_area_field(name, title, *args)
    args[0] ||= {}
    args.first[:col] ||= "8"
    @template.content_tag :div, class: "mdl-cell--#{args.first[:col]}-col mdl-cell--#{args.first[:col]}-col-tablet ml-color--shades-white m-8" do
      (@template.content_tag :div, class: "mdl-textfield mdl-js-textfield mdl-textfield--floating-label is-upgraded" do
        args[0] ||= {}
        args.first[:class] ||= "mdl-textfield__input"
        args.first[:rows] ||= 4 
        args.first[:id] ||= "sample5"
        str = text_area(name, *args)
        str += label(title, options[:label], class: 'mdl-textfield__label')
        str
      end)
    end
  end

  def custom_text_area_field_for_registration(name, title, options = {}, *args)
    args[0] ||= {}
    args.first[:col] ||= "12"
    @template.content_tag :div, class: "mdl-cell--#{args.first[:col]}-col mdl-cell--#{args.first[:col]}-col-tablet ml-color--shades-white m-8" do
      (@template.content_tag :div, class: "bs-component", :style => "display: #{options[:message_display].present? ? options[:message_display] : ""}; font-family: #{options["font_style"].present? ? options["font_style"] : ""};" do
        @template.content_tag :div, class: "form-group #{options["background"] == "false" ? "" : set_highlight_class(name)} #{name}", :style => "display: #{(options[:display] == "false") ? "none" : ""};" do
          str = @template.label("", "#{title}", class: "col-lg-4 control-label txtcase")
          str += @template.content_tag :div, class: "col-lg-7" do
            @template.content_tag :div, class: "bs-component" do 
              args[0] ||= {}
              args.first[:class] ||= "form-control textarea-grow"
              args.first[:rows] ||= 4 
              args.first[:id] ||= name.to_s + "_sample5"
              str = text_area(name, *args)
            end
          end
          str += @template.content_tag :span, class: "col-lg-1" do
            @template.link_to("?" ,"/whats_this/#{options[:view_popup][:image_path] rescue ""}", rel: "#{options[:view_popup][:rel] rescue ""}", title: "#{options[:view_popup][:title] rescue ""}", :class =>"fancybox whatsImg") if options[:view_popup].present?
          end
        end
      end)
    end
  end


  def custom_submit_button(value=nil, options={})
    @template.content_tag :div, class: "mdl-button mdl-js-button mdl-button--raised mdl-color--light-blue-600 mdl-js-ripple-effect btnsubmit floatRight m-l-18" do
      @template.content_tag :div, class: "mdl-cell--12-col mdl-cell--12-col-tablet" do
        str = submit_tag(value, options={:onClick =>'showSuccessToast();', :class => options[:class]})
      end  
    end 
  end

  def custom_submit_button1(value=nil, options={})
    @template.content_tag :div, class: "mdl-button mdl-js-button mdl-button--raised mdl-color--light-blue-600 mdl-js-ripple-effect btnsubmit m-l-18" do
      @template.content_tag :div, class: "mdl-cell--12-col mdl-cell--12-col-tablet" do
        str = submit_tag(value)
      end  
    end 
  end

  def resolve_boolean_parameter resource, attribute, options = {}
    default = options.delete(:default)
    return default unless params[:utf8]
    return params[resource][attribute] == "1"
  end 
  


  # def custom_submit_button(value=nil, options={})
  #   @template.content_tag :div, class: "mdl-button mdl-js-button mdl-button--raised mdl-color--light-blue-600 mdl-js-ripple-effect btnsubmit" do
  #     @template.content_tag :div, class: "mdl-cell--12-col mdl-cell--12-col-tablet" do
  #       str = submit_tag(value, options={})
  #     end  
  #   end 
  # end

  def display_tag
    args[0] ||= {}
    args.first[:col] ||= "8"
    @template.content_tag :div, class: "mdl-grid mdl-cell--#{args.first[:col]}-col no-p-l no-p-t no-p-r no-p-b" do
      @template.content_tag :div, class: "mdl-cell--5-col mdl-cell--4-col-tablet m-8" do
        
      end
    end      
  end  

 
   
  # def form_group(method, options={})
  #   class_def = 'form-group'
  #   class_def << ' has-error' unless @object.errors[method].blank?
  #   class_def << " #{options[:class]}" if options[:class].present?
  #   options[:class] = class_def
  #   @template.content_tag(:div, options) { yield }
  # end


  # def div_text_field(method, options={})
  #   # str = content_tag :div, '', :class => "row" 
  #   # str += content_tag :div, "", :class => "input-field col s12"
  #   # str += content_tag :label, "First"
  #   # field_errors = object.errors[method].join(', ') if !@object.errors[method].blank?
  #   # #super + (@template.content_tag(:span, @object.errors.full_messages_for(method), class: 'help-block') if field_errors)
  #   # super + str
  #   @template.content_tag(:div, '', :class => 'row'
  #     @template.text_field(:div, '', :class => 'input-field col s12'
  #       @object_name, method, tag_value, objectify_options(options)
  #     )
  #   )
  # end




  def custom_text_field(name, title, *args)
    args[0] ||= {}
    args.first[:col] ||= "12"
    @template.content_tag :div, class: "mdl-cell--#{args.first[:col]}-col mdl-cell--#{args.first[:col]}-col-tablet ml-color--shades-white m-8" do
      @template.content_tag :div, class: "bs-component", :style => "display: #{args[0][:message_display].present? ? args[0][:message_display] : ""}"do
        @template.content_tag :div, class: "form-group #{args[0][:admin_theme].present? ? args[0][:admin_theme] : "" rescue ""} #{args[0]["background"] == "false" ? "" : (args[0][:route].present? ? set_highlight_class1(name,args[0][:field_name]) : set_highlight_class(name))}" do
          str = @template.label("", "#{title}", class: "col-lg-4 control-label", id: "#{name}_label")
          str += @template.content_tag :div, class: "col-lg-7" do
            @template.content_tag :span, class: "append-icon right" do
              @template.content_tag :i, :class => "fa fa-gear"
            end
            if args.first[:class].blank?
              args.first[:class] = "form-control"
            else
              args.first[:class] = "form-control #{args.first[:class]}"
            end
            text_field(name, args.first)
          end
          str += @template.content_tag :span, class: "col-lg-1" do
            @template.link_to(" ? " ,"/whats_this/#{args.first[:view_popup][:image_path] rescue ""}", rel: "#{args.first[:view_popup][:rel] rescue "#{name}"}", title: "#{args.first[:view_popup][:title] rescue ""}", :class =>"fancybox whatsImg") if args.first[:view_popup].present?
          end
          str
        end
      end      
    end
  end


    def custom_text_field_for_user_qna(name, title, *args)
    args[0] ||= {}
    args.first[:col] ||= "12"
    @template.content_tag :div, class: "mdl-cell--#{args.first[:col]}-col mdl-cell--#{args.first[:col]}-col-tablet ml-color--shades-white m-8" do
      @template.content_tag :div, class: "bs-component", :style => "display: #{args[0][:message_display].present? ? args[0][:message_display] : ""}"do
        @template.content_tag :div, class: "form-group #{args[0][:admin_theme].present? ? args[0][:admin_theme] : "" rescue ""} #{args[0]["background"] == "false" ? "" : (args[0][:route].present? ? set_highlight_class1(name,args[0][:field_name]) : set_highlight_class(name))}" do
          str = @template.label("", "#{title}", class: "col-lg-4 control-label", id: "#{name}_label")
          str += @template.content_tag :div, class: "col-lg-7" do
            @template.content_tag :span, class: "append-icon right" do
              @template.content_tag :i, :class => "fa fa-gear"
            end
            if args.first[:class].blank?
              args.first[:class] = "form-control"
            else
              args.first[:class] = "form-control #{args.first[:class]}"
            end
            text_field(name, args.first)
          end
          str += @template.content_tag :span, class: "col-lg-1" do
            @template.link_to(" ? " ,"/whats_this/#{args.first[:view_popup][:image_path] rescue ""}", rel: "#{args.first[:view_popup][:rel] rescue "#{name}"}", title: "#{args.first[:view_popup][:title] rescue ""}", :class =>"fancybox whatsImg") if args.first[:view_popup].present?
          end
          str
        end
      end      
    end
  end

  def custom_text_field_for_sign_up(name, title, *args)
    args[0] ||= {}
    args.first[:col] ||= "12"
    @template.content_tag :div, class: "mdl-cell--#{args.first[:col]}-col mdl-cell--#{args.first[:col]}-col-tablet ml-color--shades-white m-8" do
      @template.content_tag :div, class: "bs-component", :style => "display: #{args[0][:message_display].present? ? args[0][:message_display] : ""}"do
        @template.content_tag :div, class: "form-group #{args[0][:admin_theme].present? ? args[0][:admin_theme] : "" rescue ""} #{args[0]["background"] == "false" ? "" : (args[0][:route].present? ? set_highlight_class1(name,args[0][:field_name]) : set_highlight_class(name))}" do
          str = @template.label("", "#{title}", class: "col-lg-4 control-label", id: "#{name}_label")
          str += @template.content_tag :div, class: "col-lg-7" do
            @template.content_tag :span, class: "append-icon right" do
              @template.content_tag :i, :class => "fa fa-gear"
            end
            if args.first[:class].blank?
              args.first[:class] = "form-control"
            else
              args.first[:class] = "form-control #{args.first[:class]}"
            end
            if ["password","password_confirmation"].include? name.to_s
              password_field(name, args.first)
            else
              text_field(name, args.first)
            end
          end
          str
        end
      end      
    end
  end  

  # def custom_text_field_for_venue(name, title, *args)
  #   args[0] ||= {}
  #   args.first[:col] ||= "12"
  #   @template.content_tag :div, class: "mdl-cell--#{args.first[:col]}-col mdl-cell--#{args.first[:col]}-col-tablet ml-color--shades-white m-8" do
  #     @template.content_tag :div, class: "bs-component", :style => "display: #{args[0][:message_display].present? ? args[0][:message_display] : ""}"do
  #       @template.content_tag :div, class: "form-group #{args[0][:admin_theme].present? ? args[0][:admin_theme] : "" rescue ""} #{args[0]["background"] == "false" ? "" : (args[0][:route].present? ? set_highlight_class1(name,args[0][:field_name]) : set_highlight_class(name))}" do
  #         str = @template.label("", "#{title}", class: "col-lg-4 control-label", id: "#{name}_label")
  #         str += @template.content_tag :div, class: "col-lg-7" do
  #           @template.content_tag :span, class: "append-icon right" do
  #             @template.content_tag :i, :class => "fa fa-gear"
  #           end
  #           if args.first[:class].blank?
  #             args.first[:class] = "form-control"
  #           else
  #             args.first[:class] = "form-control #{args.first[:class]}"
  #           end
  #           text_field(name, args.first)
  #         end
  #         str += @template.content_tag :span, class: "col-lg-1" do
  #           @template.link_to(" ? " ,"/whats_this/#{args.first[:view_popup][:image_path] rescue ""}", rel: "#{args.first[:view_popup][:rel] rescue "#{name}"}", title: "#{args.first[:view_popup][:title] rescue ""}", :class =>"fancybox whatsImg") if args.first[:view_popup].present?
  #         end
  #         str
  #       end
  #     end      
  #   end
  # end

  def custom_text_field_for_edm_social_icon(name, title, id_match_with_checkbox=nil, *args)
    args[0] ||= {}
    args.first[:col] ||= "12"
    @template.content_tag :div, class: "mdl-cell--#{args.first[:col]}-col mdl-cell--#{args.first[:col]}-col-tablet ml-color--shades-white  input_box_url", id: "edm_check_#{id_match_with_checkbox}" do
      @template.content_tag :div, class: "bs-component", :style => "display: #{args[0][:message_display].present? ? args[0][:message_display] : ""}"do
        @template.content_tag :div, class: " #{args[0][:admin_theme].present? ? args[0][:admin_theme] : "" rescue ""} #{args[0]["background"] == "false" ? "" : (args[0][:route].present? ? set_highlight_class1(name,args[0][:field_name]) : set_highlight_class(name))}" do
          str = @template.label("", "#{title}", class: "col-lg-1 control-label", id: "#{name}_label")
          str += @template.content_tag :div, class: "col-lg-11" do
            @template.content_tag :span, class: "append-icon right" do
              @template.content_tag :i, :class => "fa fa-gear"
            end
            if args.first[:class].blank?
              args.first[:class] = "form-control"
            else
              args.first[:class] = "form-control #{args.first[:class]}"
            end
            text_field(name, args.first)
          end
          str += @template.content_tag :span, class: "col-lg-1" do
            @template.link_to(" ? " ,"/whats_this/#{args.first[:view_popup][:image_path] rescue ""}", rel: "#{args.first[:view_popup][:rel] rescue "#{name}"}", title: "#{args.first[:view_popup][:title] rescue ""}", :class =>"fancybox whatsImg") if args.first[:view_popup].present?
          end
          str
        end
      end      
    end
  end

  # def custom_text_field_remove_white_backg(name, title, *args)
  #   args[0] ||= {}
  #   args.first[:col] ||= "12"
  #   @template.content_tag :div, class: "mdl-cell--#{args.first[:col]}-col mdl-cell--#{args.first[:col]}-col-tablet" do
  #     @template.content_tag :div, class: "bs-component", :style => "display: #{args[0][:message_display].present? ? args[0][:message_display] : ""}"do
  #       @template.content_tag :div, class: "form-group #{args[0][:admin_theme].present? ? args[0][:admin_theme] : "" rescue ""} #{args[0]["background"] == "false" ? "" : (args[0][:route].present? ? set_highlight_class1(name,args[0][:field_name]) : set_highlight_class(name))}" do
  #         str = @template.label("", "#{title}", class: "col-lg-4 control-label", id: "#{name}_label")
  #         str += @template.content_tag :div, class: "col-lg-7" do
  #           @template.content_tag :span, class: "append-icon right" do
  #             @template.content_tag :i, :class => "fa fa-gear"
  #           end
  #           if args.first[:class].blank?
  #             args.first[:class] = "form-control"
  #           else
  #             args.first[:class] = "form-control #{args.first[:class]}"
  #           end
  #           text_field(name, args.first)
  #         end
  #         str += @template.content_tag :span, class: "col-lg-1" do
  #           @template.link_to(" ? " ,"/whats_this/#{args.first[:view_popup][:image_path] rescue ""}", rel: "#{args.first[:view_popup][:rel] rescue "#{name}"}", title: "#{args.first[:view_popup][:title] rescue ""}", :class =>"fancybox whatsImg") if args.first[:view_popup].present?
  #         end
  #         str
  #       end
  #     end      
  #   end
  # end

  def custom_text_field_speaker(name, title, *args)
    args[0] ||= {}
    args.first[:col] ||= "12"
    @template.content_tag :div, class: "mdl-cell--#{args.first[:col]}-col mdl-cell--#{args.first[:col]}-col-tablet ml-color--shades-white m-8" do
      @template.content_tag :div, class: "bs-component" do
        @template.content_tag :div, class: "form-group #{args[0]["background"] == "false" ? "" : (args[0][:route].present? ? set_highlight_class1(name,args[0][:field_name]) : set_highlight_class(name))}", :style => "display : #{args[0][:display_field] rescue ""}" do
          str = @template.label("", "#{title}", class: "col-lg-4 control-label", id: "#{name}_label")
          str += @template.content_tag :div, class: "col-lg-7" do
            @template.content_tag :span, class: "append-icon right" do
              @template.content_tag :i, :class => "fa fa-gear"
            end
            if args.first[:class].blank?
              args.first[:class] = "form-control"
            else
              args.first[:class] = "form-control #{args.first[:class]}"
            end
            text_field(name, args.first)
          end
          str += @template.content_tag :span, class: "col-lg-1" do
            @template.link_to(" ? " ,"/whats_this/#{args.first[:view_popup][:image_path] rescue ""}", rel: "#{args.first[:view_popup][:rel] rescue "#{name}"}", title: "#{args.first[:view_popup][:title] rescue ""}", :class =>"fancybox whatsImg") if args.first[:view_popup].present?
          end
          str
        end
      end      
    end
  end




  def custom_text_field_full_name(name, title,*args)
    args[0] ||= {}
    args.first[:col] ||= "12"
    @template.content_tag :div, class: "mdl-cell--#{args.first[:col]}-col mdl-cell--#{args.first[:col]}-col-tablet ml-color--shades-white m-8" do
      @template.content_tag :div, class: "bs-component" do
        @template.content_tag :div, class: "form-group #{args[0][:route].present? ? set_highlight_class1(name,args[0][:field_name]) : set_highlight_class(name)}" do
          str = @template.label("", "#{title}", class: "col-lg-4 control-label", id: "#{name}_label")
          str += @template.content_tag :div, class: "col-lg-7" do
            @template.content_tag :span, class: "append-icon right" do
              @template.content_tag :i, :class => "fa fa-gear"
            end
            if args.first[:class].blank?
              args.first[:class] = "form-control"
            else
              args.first[:class] = "form-control #{args.first[:class]}"
            end
            str1 = text_field(name, args.first)
            str1 += @template.content_tag :div, class: "field_with_errors" do
              @template.content_tag :div, class: "errorMessage span" do
                args[0][:error_message].present? ? args[0][:error_message].join(): ""  rescue ""
              end
            end
          end
          str
        end
      end      
    end
  end

  def custom_text_field_manage_mobile_app(name, title, *args)
    args[0] ||= {}
    args.first[:col] ||= "12"
    @template.content_tag :div, class: "mdl-cell--#{args.first[:col]}-col mdl-cell--#{args.first[:col]}-col-tablet ml-color--shades-white m-8" do
      @template.content_tag :div, class: "bs-component" do
        @template.content_tag :div, class: "form-group #{args[0][:route].present? ? set_highlight_class1(name,args[0][:field_name]) : set_highlight_class(name)}" do
          str = @template.label("", "#{title}", class: "col-lg-4 control-label", id: "#{name}_label")
          str += @template.content_tag :div, class: "col-lg-7" do
            @template.content_tag :span, class: "append-icon right" do
              @template.content_tag :i, :class => "fa fa-gear"
            end
            if args.first[:class].blank?
              args.first[:class] = ""
            else
              args.first[:class] = "form-control #{args.first[:class]}"
            end
            text_field(name, :readonly => true, :class => "form-control")
          end
        end
      end      
    end
  end


  def custom_password_field(name, title, *args)
    args[0] ||= {}
    args.first[:col] ||= "12"
    @template.content_tag :div, class: "mdl-cell--#{args.first[:col]}-col mdl-cell--#{args.first[:col]}-col-tablet ml-color--shades-white m-8" do
      @template.content_tag :div, class: "bs-component" do
        @template.content_tag :div, class: "form-group #{args[0][:route].present? ? set_highlight_class1(name,args[0][:field_name]) : set_highlight_class(name)}" do
          str = @template.label("", "#{title}", class: "col-lg-4 control-label", id: "#{name}_label")
          str += @template.content_tag :div, class: "col-lg-7" do
            @template.content_tag :span, class: "append-icon right" do
              @template.content_tag :i, :class => "fa fa-gear"
            end
            if args.first[:class].blank?
              args.first[:class] = "form-control"
            else
              args.first[:class] = "form-control #{args.first[:class]}"
            end
            password_field(name, args.first)
          end
          str += @template.content_tag :span, class: "col-lg-1" do
            @template.link_to(" ? " ,"/whats_this/#{args.first[:view_popup][:image_path] rescue ""}", rel: "#{args.first[:view_popup][:rel] rescue "#{name}"}", title: "#{args.first[:view_popup][:title] rescue ""}", :class =>"fancybox whatsImg") if args.first[:view_popup].present?
          end
          str
        end
      end      
    end
  end

  def custom_text_field_display(name, title,id, *args)
    args[0] ||= {}
    args.first[:col] ||= "12"
    @template.content_tag :div, class: "mdl-cell--#{args.first[:col]}-col mdl-cell--#{args.first[:col]}-col-tablet ml-color--shades-white m-8" do
      @template.content_tag :div, class: "bs-component" do
        @template.content_tag :div, class: "form-group #{set_highlight_class(name)}", :style => "display: #{(id[:display] == "false") ? "none" : ""};" do
          str = @template.label("", "#{title}", class: "col-lg-4 control-label")
          str += @template.content_tag :div, class: "col-lg-7" do
            @template.content_tag :span, class: "append-icon right" do
              @template.content_tag :i, :class => "fa fa-gear"
            end
            if args.first[:class].blank?
              args.first[:class] = "form-control pick-a-color"
            else
              args.first[:class] = "form-control #{args.first[:class]}"
            end
            text_field(name, args.first)
          end
          str += @template.content_tag :span, class: "col-lg-1" do
            @template.link_to(" ? " ,"/whats_this/#{id[:view_popup][:image_path] rescue ""}", rel: "#{id[:view_popup][:rel] rescue "#{name}"}", title: "#{id[:view_popup][:title] rescue ""}", :class =>"fancybox whatsImg") if id[:view_popup].present?
          end
          str
        end
      end      
    end
  end


  def custom_text_field_display1(name, title,id, *args)
    args[0] ||= {}
    args.first[:col] ||= "12"
    @template.content_tag :div, class: "mdl-cell--#{args.first[:col]}-col mdl-cell--#{args.first[:col]}-col-tablet ml-color--shades-white m-8" do
      @template.content_tag :div, class: "bs-component" do
        @template.content_tag :div, class: "form-group #{id[:highlight_class]}", :style => "display: #{(id[:display] == "false") ? "none" : ""};" do
          str = @template.label("", "#{title}", class: "col-lg-4 control-label")
          str += @template.content_tag :div, class: "col-lg-7" do
            @template.content_tag :span, class: "append-icon right" do
              @template.content_tag :i, :class => "fa fa-gear"
            end
            if args.first[:class].blank?
              args.first[:class] = "form-control pick-a-color"
            else
              args.first[:class] = "form-control #{args.first[:class]}"
            end
            text_field(name, args.first)
          end
          str += @template.content_tag :span, class: "col-lg-1" do
            @template.link_to(" ? " ,"/whats_this/#{id[:view_popup][:image_path] rescue ""}", rel: "#{id[:view_popup][:rel] rescue "#{name}"}", title: "#{id[:view_popup][:title] rescue ""}", :class =>"fancybox whatsImg") if id[:view_popup].present?
          end
          str
        end
      end      
    end
  end

  def custom_text_fieldTime(name, title, *args)
    args[0] ||= {}
    args.first[:col] ||= "12"
    @template.content_tag :div, class: "mdl-cell--#{args.first[:col]}-col mdl-cell--#{args.first[:col]}-col-tablet ml-color--shades-white m-8" do
      @template.content_tag :div, class: "bs-component" do
        @template.content_tag :div, class: "form-group #{set_highlight_class(name)}" do
          
          @template.content_tag :div, class: "col-lg-12" do
            @template.content_tag :span, class: "append-icon right" do
              @template.content_tag :i, :class => "fa fa-gear"
            end
            # if (args[0].present? and args[0][:id].present?)
            #   text_field(name, :class => "form-control", :id => (args[0].present? and args[0][:id].present? ) ? args[0][:id] : '')
            # else
            #   text_field(name, :class => "form-control")
            # end
            if args.first[:class].blank?
              args.first[:class] = "form-control"
            else
              args.first[:class] = "form-control #{args.first[:class]}"
            end
            text_field(name, args.first)
          end
        end
      end      
    end
  end

  def custom_text_field_date(name, title, *args)
    args[0] ||= {}
    args.first[:col] ||= "12"     
    str = @template.content_tag :div, class: "col-lg-4" do
      if args.first[:class].blank?
        args.first[:class] = "form-control"
      else
        args.first[:class] = "form-control #{args.first[:class]}"
      end
      text_field(name, args.first)
    end
    str
  end

  def custom_text_field_for_date(name, title, *args)
    args[0] ||= {}
    args.first[:col] ||= "12"     
    str = @template.content_tag :div, class: "col-lg-7" do
      if args.first[:class].blank?
        args.first[:class] = "form-control"
      else
        args.first[:class] = "form-control #{args.first[:class]}"
      end
      text_field(name, args.first)
    end
    str
  end

  def custom_text_field_quiz(name, title,answer,*args)
    args[0] ||= {}
    args.first[:col] ||= "12"
    @template.content_tag :div, class: "mdl-cell--#{args.first[:col]}-col mdl-cell--#{args.first[:col]}-col-tablet ml-color--shades-white m-8" do
      @template.content_tag :div, class: "bs-component" do
        @template.content_tag :div, class: "form-group #{args[0]["background"] == "false" ? "" : args[0][:route].present? ? set_highlight_class1(name,args[0][:field_name]) : set_highlight_class(name)}" do
          str = @template.label("", "#{title}", class: "col-lg-3 control-label", id: "#{name}_label")
          str += @template.content_tag :div, class: "col-lg-7" do
            dynamic_tag = text_field(name, class: "form-control")
            
          end
          str += @template.content_tag :div, class: "col-lg-2 md-checkbox quiz-checkbox" do
            str = @template.label("", " ", class: "", for: "#{name}_label") do 
              str1 = check_box_tag("quiz[correct_ans_#{name}]", "#{name}", (answer == name.to_s), id: "#{name}_label", class: "") 
              str1 += @template.content_tag :span, class: "checkbox" do
              end
              
            end  
          end 
          str
        end
      end      
    end
  end

  def custom_text_field_quiz_question(name, title,*args)
    args[0] ||= {}
    args.first[:col] ||= "12"
    @template.content_tag :div, class: "mdl-cell--#{args.first[:col]}-col mdl-cell--#{args.first[:col]}-col-tablet ml-color--shades-white m-8" do
      @template.content_tag :div, class: "bs-component" do
        @template.content_tag :div, class: "form-group #{ args[0]["background"] == "false" ? "" : (args[0][:route].present? ? set_highlight_class1(name,args[0][:field_name]) : set_highlight_class(name))}" do
          str = @template.label("", "#{title}", class: "col-lg-3 control-label", id: "#{name}_label")
          str += @template.content_tag :div, class: "col-lg-7" do
            dynamic_tag = text_field(name, class: "form-control")
            
          end
          str += @template.content_tag :div,"Correct Option", class: "col-lg-2" 
          str
        end
      end      
    end
  end

  def custom_text_area_field(name, title, options = {}, *args)
    args[0] ||= {}
    args.first[:col] ||= "12"
    @template.content_tag :div, class: "mdl-cell--#{args.first[:col]}-col mdl-cell--#{args.first[:col]}-col-tablet ml-color--shades-white m-8" do
      (@template.content_tag :div, class: "bs-component", :style => "display: #{options[:message_display].present? ? options[:message_display] : ""}" do
        @template.content_tag :div, class: "form-group #{options["background"] == "false" ? "" : set_highlight_class(name)} #{name}", :style => "display: #{(options[:display] == "false") ? "none" : ""};" do
          str = @template.label("", "#{title}", class: "col-lg-4 control-label txtcase")
          str += @template.content_tag :div, class: "col-lg-7" do
            @template.content_tag :div, class: "bs-component" do 
              args[0] ||= {}
              args.first[:class] ||= "form-control textarea-grow"
              args.first[:rows] ||= 4 
              args.first[:id] ||= name.to_s + "_sample5"
              str = text_area(name, *args)
            end
          end
          str += @template.content_tag :span, class: "col-lg-1" do
            @template.link_to("?" ,"/whats_this/#{options[:view_popup][:image_path] rescue ""}", rel: "#{options[:view_popup][:rel] rescue ""}", title: "#{options[:view_popup][:title] rescue ""}", :class =>"fancybox whatsImg") if options[:view_popup].present?
          end
        end
      end)
    end
  end


  # def custom_text_area_field_remove_white_backg(name, title, options = {}, *args)
  #   args[0] ||= {}
  #   args.first[:col] ||= "12"
  #   @template.content_tag :div, class: "mdl-cell--#{args.first[:col]}-col mdl-cell--#{args.first[:col]}-col-tablet" do
  #     (@template.content_tag :div, class: "bs-component", :style => "display: #{options[:message_display].present? ? options[:message_display] : ""}" do
  #       @template.content_tag :div, class: "form-group #{options["background"] == "false" ? "" : set_highlight_class(name)} #{name}", :style => "display: #{(options[:display] == "false") ? "none" : ""};" do
  #         str = @template.label("", "#{title}", class: "col-lg-4 control-label txtcase")
  #         str += @template.content_tag :div, class: "col-lg-7" do
  #           @template.content_tag :div, class: "bs-component" do 
  #             args[0] ||= {}
  #             args.first[:class] ||= "form-control textarea-grow"
  #             args.first[:rows] ||= 4 
  #             args.first[:id] ||= name.to_s + "_sample5"
  #             str = text_area(name, *args)
  #           end
  #         end
  #         str += @template.content_tag :span, class: "col-lg-1" do
  #           @template.link_to("?" ,"/whats_this/#{options[:view_popup][:image_path] rescue ""}", rel: "#{options[:view_popup][:rel] rescue ""}", title: "#{options[:view_popup][:title] rescue ""}", :class =>"fancybox whatsImg") if options[:view_popup].present?
  #         end
  #       end
  #     end)
  #   end
  # end

  def custom_text_area_field1(name, title, *args)
    args[0] ||= {}
    args.first[:col] ||= "12"
    @template.content_tag :div, class: "mdl-cell--#{args.first[:col]}-col mdl-cell--#{args.first[:col]}-col-tablet ml-color--shades-white m-8 #{args[0][:klass]}", :style => "display: #{args[0][:display] == "true" ? "block" : "none"}" do
      (@template.content_tag :div, class: "bs-component", :style => "display: #{options[:message_display].present? ? options[:message_display] : ""}" do
        @template.content_tag :div, class: "form-group" do
          str = @template.label("", "#{title}", class: "col-lg-4 control-label")
          str += @template.content_tag :div, class: "col-lg-7" do
            @template.content_tag :div, class: "bs-component" do 
              args[0] ||= {}
              args.first[:class] = "form-control textarea-grow"
              args.first[:rows] ||= 4 
              args.first[:id] ||= "sample5"
              str = text_area(name, *args)
            end
          end
        end
      end)
    end
  end


  def new_custom_file_browser_field(name, title, id,*args)
    args[0] ||= {}
    args.first[:col] ||= "12"
    @template.content_tag :div, class: "mdl-cell--#{args.first[:col]}-col mdl-cell--#{args.first[:col]}-col-tablet ml-color--shades-white allcp-form m-8", :style => "margin-bottom: 10px;" do
      @template.content_tag :div, class: "bs-component" do
        @template.content_tag :div, class: "form-group #{id["background"] == "false" ? "" : set_image_uploader_color(id[:value],id[:action])}" do
          str = @template.content_tag :span, class: "col-lg-4", id: "#{name}_label", :style => "display: #{(id[:display].present? and id[:display] == "false") ?  "none" : ""  }" do
            @template.label("", "#{title}", class: "control-label", style: "float: right;")
          end
          str += @template.content_tag :div, class: "col-lg-7", style: "display: #{(id[:display].present? and id[:display] == "false") ?  "none" : ""  }" do
            @template.content_tag :div, class: "section" do
              @template.content_tag :label, class: "field file" do
                str = @template.content_tag :span ,"Choose File", class: "button btn-primary "
                str += file_field(name, id: id[:id], class: "gui-file")
                str += text_field_tag("text_file_name","", id: "1#{id[:id]}", class: "gui-input", :value => "#{id[:value].nil? ? "there is no Attachment Available !" : id[:value]}", :read_only => true)
                str
              end  
            end
          end
          str += @template.content_tag :span, class: "col-lg-1",id: "this_#{id[:id]}", style: "display: #{(id[:display].present? and id[:display] == "false") ?  "none" : ""  }" do
            @template.link_to("?" ,"/whats_this/#{id[:view_popup][:image_path] rescue ""}", rel: "#{id[:view_popup][:rel] rescue ""}", title: "#{id[:view_popup][:title] rescue ""}", :class =>"fancybox whatsImg") if id[:view_popup].present?
          end  
        end    
      end
    end 
  end

  def icon_library_browser_field(name, title, id,*args)
    args[0] ||= {}
    args.first[:col] ||= "12"
    @template.content_tag :div, class: "mdl-cell--#{args.first[:col]}-col mdl-cell--#{args.first[:col]}-col-tablet ml-color--shades-white allcp-form m-8", :style => "margin-bottom: 10px;" do
      @template.content_tag :div, class: "bs-component" do
        @template.content_tag :div, class: "form-group #{id["background"] == "false" ? "" : set_image_uploader_color(id[:value],id[:action])}" do
          str = @template.content_tag :span, class: "col-lg-5", id: "#{name}_label", :style => "display: #{(id[:display].present? and id[:display] == "false") ?  "none" : ""  }" do
            @template.label("", "#{title}", class: "control-label", style: "float: right;")
          end
          str += @template.content_tag :div, class: "col-lg-6", style: "display: #{(id[:display].present? and id[:display] == "false") ?  "none" : ""  }" do
            @template.content_tag :div, class: "section" do
              @template.content_tag :label, class: "field file" do
                str = @template.content_tag :span ,"Choose File", class: "button btn-primary "
                str += file_field(name, id: id[:id], class: "gui-file")
                str += text_field_tag("text_file_name","", id: "1#{id[:id]}", class: "gui-input", :value => "#{id[:value].nil? ? "there is no Attachment Available !" : id[:value]}", :read_only => true)
                str
              end  
            end
          end
          str += @template.content_tag :span, class: "col-lg-1",id: "this_#{id[:id]}", style: "display: #{(id[:display].present? and id[:display] == "false") ?  "none" : ""  }" do
            @template.link_to("?" ,"/whats_this/#{id[:view_popup][:image_path] rescue ""}", rel: "#{id[:view_popup][:rel] rescue ""}", title: "#{id[:view_popup][:title] rescue ""}", :class =>"fancybox whatsImg") if id[:view_popup].present?
          end  
        end    
      end
    end 
  end

  def custom_file_browser_field_app(name, title, id,*args)
    args[0] ||= {}
    args.first[:col] ||= "12"
    @template.content_tag :div, class: "mdl-cell--#{args.first[:col]}-col mdl-cell--#{args.first[:col]}-col-tablet ml-color--shades-white allcp-form m-8" do
      @template.content_tag :div, class: "bs-component" do
        @template.content_tag :div, class: "form-group #{set_image_uploader_color(id[:value],id[:action])}" do
          str = @template.content_tag :span, class: "col-lg-4", id: "#{name}_label", :style => "display: #{(id[:display].present? and id[:display] == "false") ?  "none" : ""  }" do
            @template.label("", "#{title}", class: "control-label", style: "float: right;")
          end
          str += @template.content_tag :div, class: "col-lg-7", style: "display: #{(id[:display].present? and id[:display] == "false") ?  "none" : ""  }" do
            @template.content_tag :div, class: "section" do
              @template.content_tag :label, class: "field file" do
                str = @template.content_tag :span ,"Choose File", class: "button btn-primary "
                str += file_field(name, id: id[:id], class: "gui-file")
                str += text_field_tag("text_file_name","", id: "1#{id[:id]}", class: "gui-input", :value => "#{id[:value].nil? ? "there is no Attachment Available !" : id[:value]}", :read_only => true)
                str
              end  
            end
          end
          str += @template.content_tag :span, class: "col-lg-1",id: "this_#{id[:id]}", :style => "display: #{(id[:value].present? and id[:value] != "Image not present.") ? "" : "none" }" do
            @template.link_to("Download" , "/admin/downloads/new?url=#{id[:value]}", :target => '_blank')
          end  
        end    
      end
    end 
  end

  def new_custom_file_browser_field_login(name, title, id,*args)
    args[0] ||= {}
    args.first[:col] ||= "12"
    @template.content_tag :div, class: "mdl-cell--#{args.first[:col]}-col mdl-cell--#{args.first[:col]}-col-tablet ml-color--shades-white allcp-form m-8" do
      @template.content_tag :div, class: "bs-component" do
        @template.content_tag :div, class: "form-group #{set_image_uploader_color(id[:value],id[:action])}", :style => "display: #{(id[:display] == "false") ? "none" : ""};" do
          #str = @template.label("", "#{title}", class: "col-lg-4 control-label")
          str = @template.content_tag :span, class: "col-lg-4", id: "#{name}_label", :style => "display: #{(id[:display].present? and id[:display] == "false") ?  "none" : ""  }" do
            str = @template.link_to("?" ,"/whats_this/#{id[:view_popup][:image_path] rescue ""}", rel: "#{id[:view_popup][:rel] rescue ""}", title: "#{id[:view_popup][:title] rescue ""}", :class =>"fancybox whatsImg") if id[:view_popup].present?
            if str.present?
              str += @template.label("", "#{title}", class: "control-label", style: "float: right;")
            else
              str = @template.label("", "#{title}", class: "control-label", style: "float: right;")
            end
          end
          str += @template.content_tag :div, class: "col-lg-7" do
            @template.content_tag :div, class: "section" do
              @template.content_tag :label, class: "field file" do
                str = @template.content_tag :span ,"Choose File", class: "button btn-primary "
                str += file_field(name, id: id[:id], class: "gui-file")
                str += text_field_tag("text_file_name","", id: "1#{id[:id]}", class: "gui-input", :value => "#{id[:value].nil? ? "there is no Attachment Available !" : id[:value]}", :read_only => true)
                str
              end  
            end
          end
            
        end    
      end
    end 
  end


  def new_custom_file_browser_field_menu(name, title, id,*args)
    args[0] ||= {}
    args.first[:col] ||= "12"
    @template.content_tag :div, class: "mdl-cell--#{args.first[:col]}-col mdl-cell--#{args.first[:col]}-col-tablet ml-color--shades-white allcp-form m-8 feature_icon_upload #{id[:add_class].present? ? id[:add_class] : ""}", :style => "display: #{(id[:display_icon].present? and id[:display_icon] == "no") ? "none" : ""}" do
      @template.content_tag :div, class: "bs-component" do
        @template.content_tag :div, class: "form-group #{id[:value].blank? ? "has-warning" : "has-success"}" do
          str = @template.label("", "#{title}", class: "col-lg-4 control-label")
          str += @template.content_tag :div, class: "col-lg-7" do
            @template.content_tag :div, class: "section" do
              @template.content_tag :label, class: "field file" do
                str = @template.content_tag :span ,"Choose File", class: "button btn-primary "
                str += file_field(name, id: id[:id], class: "gui-file")
                str += text_field_tag("text_file_name","", id: "1#{id[:id]}", class: "gui-input", :value => "#{id[:value].nil? ? "there is no Attachment Available !" : id[:value]}", :read_only => true)
                str
              end  
            end
          end
          str += @template.content_tag :div, class: "col-lg-1" do
            str1 = image_tag(id[:image_url], :size => "40x40", :class =>"#{id[:menu_class]}")
            str1 += @template.link_to("?" ,"/whats_this/#{id[:view_popup][:image_path] rescue ""}", rel: "#{id[:view_popup][:rel] rescue ""}", title: "#{id[:view_popup][:title] rescue ""}", :class =>"fancybox whatsImg menuwhatsImg") if id[:view_popup].present?
          end
        end    
      end
    end 
  end

  def set_highlight_class(name)
    get_obj = self.object ||  self.options[:parent_builder].object
    allow = get_obj.new_record? if name != :about
    allow = get_obj.about.nil? if name == :about
    unless allow
      if name == :event_background_image
        (get_obj.event_background_image_file_name.present?) ? "has-success" : "has-warning"
      else
        (get_obj.attribute_present? name) ? "has-success" : "has-warning"
      end  
    end
  end

  def set_highlight_class1(name,field_name)
    get_obj = self.object ||  self.options[:parent_builder].object
    (get_obj[field_name][name].present?) ? "has-success" : "has-warning"
  end

  def custom_text_field_name(name, title, *args)
    @template.content_tag :div, class: "mdl-cell--12-col mdl-cell--12-col-tablet ml-color--shades-white m-8" do
      @template.content_tag :div, class: "bs-component" do
        @template.content_tag :div, class: "form-group #{set_highlight_class(name)}" do
          str = @template.label("", "#{title}", class: "col-lg-3 control-label")
          str += @template.content_tag :div, class: "col-lg-9" do
            text_field(name, :class => "form-control")
          end  
          str
        end
      end      
    end
  end

  def icon_library_custom_text_field_name(name, title, *args)
    @template.content_tag :div, class: "mdl-cell--12-col mdl-cell--12-col-tablet ml-color--shades-white m-8" do
      @template.content_tag :div, class: "bs-component" do
        @template.content_tag :div, class: "form-group #{set_highlight_class(name)}" do
          str = @template.label("", "#{title}", class: "col-lg-5 control-label")
          str += @template.content_tag :div, class: "col-lg-6" do
            text_field(name, :class => "form-control")
          end  
          str
        end
      end      
    end
  end

  def custom_text_field_grouping(name, title, value,*args)
    display_value = JSON.parse value[:value].gsub('=>', ':') rescue nil
    actual_value = "#{display_value["value"] rescue nil}"
    actual_condition ="#{display_value["condition"] rescue nil}"
    @template.content_tag :div, class: "mdl-cell--12-col mdl-cell--12-col-tablet ml-color--shades-white m-8" do
      @template.content_tag :div, class: "bs-component" do
        @template.content_tag :div, class: "form-group" do
          str = @template.label("", "#{title}", class: "col-lg-3 control-label")
          str += @template.content_tag :div, class: "col-lg-5 #{set_highlight_class_grouping(actual_condition)}" do
            text_field("condition", :value => "#{actual_condition}", :class => "form-control attr_validation", :placeholder => "Condition")
          end
          
          str += @template.content_tag :div, class: "col-lg-4 #{set_highlight_class_grouping(actual_value)}" do
            text_field("value", :value => "#{actual_value}", :class => "form-control", :placeholder => "Value")
          end  

          # str += @template.content_tag :div, class: "col-lg-3" do
          #   text_field("#{name}_options", :value => "#{display_value[name + "_value"] rescue nil}", :class => "form-control", :placeholder => "options")
          # end
          str
        end
      end      
    end
  end

  def set_highlight_class_grouping(name)
  end
  #gopi krishna 
    def custom_text_field_for_onsite_regi(name, title, *args)
    args[0] ||= {}
    args.first[:col] ||= "12"
    @template.content_tag :div, class: "mdl-cell--#{args.first[:col]}-col mdl-cell--#{args.first[:col]}-col-tablet ml-color--shades-white m-8" do
      @template.content_tag :div, class: "bs-component", :style => "display: #{args[0][:message_display].present? ? args[0][:message_display] : ""}"do
        @template.content_tag :div, class: "form-group #{args[0][:admin_theme].present? ? args[0][:admin_theme] : "" rescue ""} #{args[0]["background"] == "false" ? "" : (args[0][:route].present? ? set_highlight_class1(name,args[0][:field_name]) : set_highlight_class(name))}" do
          str = @template.label("", "#{title}", class: "col-lg-4 col-md-4 col-sm-4 col-xs-12 control-label", id: "#{name}_label")
          str += @template.content_tag :div, class: "col-lg-7 col-md-7 col-sm-7 col-xs-12" do
            @template.content_tag :span, class: "append-icon right" do
              @template.content_tag :i, :class => "fa fa-gear"
            end
            if args.first[:class].blank?
              args.first[:class] = "form-control"
            else
              args.first[:class] = "form-control #{args.first[:class]}"
            end
            text_field(name, args.first)
          end
          str += @template.content_tag :span, class: "col-lg-1" do
            @template.link_to(" ? " ,"/whats_this/#{args.first[:view_popup][:image_path] rescue ""}", rel: "#{args.first[:view_popup][:rel] rescue "#{name}"}", title: "#{args.first[:view_popup][:title] rescue ""}", :class =>"fancybox whatsImg") if args.first[:view_popup].present?
          end
          str
        end
      end      
    end
  end
      def custom_text_area_field_for_onsite_reg(name, title, options = {}, *args)
    args[0] ||= {}
    args.first[:col] ||= "12"
    @template.content_tag :div, class: "mdl-cell--#{args.first[:col]}-col mdl-cell--#{args.first[:col]}-col-tablet ml-color--shades-white m-8" do
      (@template.content_tag :div, class: "bs-component", :style => "display: #{options[:message_display].present? ? options[:message_display] : ""}" do
        @template.content_tag :div, class: "form-group #{options["background"] == "false" ? "" : set_highlight_class(name)} #{name}", :style => "display: #{(options[:display] == "false") ? "none" : ""};" do
          str = @template.label("", "#{title}", class: "col-lg-4 col-md-4 col-sm-4 col-xs-12 control-label txtcase")
          str += @template.content_tag :div, class: "col-lg-7 col-md-7 col-sm-7 col-xs-12" do
            @template.content_tag :div, class: "bs-component" do 
              args[0] ||= {}
              args.first[:class] ||= "form-control textarea-grow"
              args.first[:rows] ||= 4 
              args.first[:id] ||= name.to_s + "_sample5"
              str = text_area(name, *args)
            end
          end
          str += @template.content_tag :span, class: "col-lg-1" do
            @template.link_to("?" ,"/whats_this/#{options[:view_popup][:image_path] rescue ""}", rel: "#{options[:view_popup][:rel] rescue ""}", title: "#{options[:view_popup][:title] rescue ""}", :class =>"fancybox whatsImg") if options[:view_popup].present?
          end
        end
      end)
    end
  end
      def custom_text_field_date_for_onsite_reg(name, title, *args)
    args[0] ||= {}
    args.first[:col] ||= "12"     
    str = @template.content_tag :div, class: "col-lg-7 col-md-7 col-sm-7 col-xs-12" do
      if args.first[:class].blank?
        args.first[:class] = "form-control"
      else
        args.first[:class] = "form-control #{args.first[:class]}"
      end
      text_field(name, args.first)
    end
    str
  end
end


