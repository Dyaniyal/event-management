class NewCustomFormBuilder < ActionView::Helpers::FormBuilder
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::CaptureHelper
  include ActionView::Helpers::AssetTagHelper


  def custom_radio_button1(method, tag_value, options = {})
    @template.radio_button(@object_name, method, tag_value, objectify_options(options)) + 
    @template.label(@object_name, options[:label], objectify_options(options))
  end
           
  
  def custom_radio_button(method, tag_value, options = {}, *args)
    @template.content_tag :label, class: "mdl-radio mdl-js-radio mdl-js-ripple-effect", for: "#{args[0].values[0]}" do
     str = @template.radio_button(@object_name, method, tag_value, id: "#{args[0].values[0]}", class: "mdl-radio__button")
      str += label(options)   
    end
  end

  def custom_radio_button2(method, tag_value, options = {}, *args)
    @template.content_tag :label, class: "mdl-radio mdl-js-radio mdl-js-ripple-effect", for: "#{args[0].values[0]}" do
     str = @template.radio_button(@object_name, method, tag_value, :checked => "#{(tag_value == "create your own theme" ? "checked" : false)}", id: "#{args[0].values[0]}", class: "mdl-radio__button")
      str += label(options)   
    end
  end

  def custom_text_field(name, title, *args)
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
  

  def custom_text_area_field(name, title, *args)
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

  def custom_submit_button(value=nil, options={})
    @template.content_tag :div, class: "mdl-button mdl-js-button mdl-button--raised mdl-color--light-blue-600 mdl-js-ripple-effect btnsubmit  m-l-18" do
      @template.content_tag :div, class: "mdl-cell--12-col mdl-cell--12-col-tablet" do
        str = submit_tag(value, options={})
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




  def new_custom_text_field(name, title, *args)
    args[0] ||= {}
    args.first[:col] ||= "8"
    @template.content_tag :div, class: "mdl-cell--#{args.first[:col]}-col mdl-cell--#{args.first[:col]}-col-tablet ml-color--shades-white m-8" do
      @template.content_tag :div, class: "bs-component" do
        @template.content_tag :div, class: "form-group" do
          str = @template.label("", "#{title}", class: "col-lg-3 control-label")
          str += @template.content_tag :div, class: "col-lg-8" do
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
          str
        end
      end      
    end
  end



  def custom_text_fieldTime(name, title, *args)
    args[0] ||= {}
    args.first[:col] ||= "8"
    @template.content_tag :div, class: "mdl-cell--#{args.first[:col]}-col mdl-cell--#{args.first[:col]}-col-tablet ml-color--shades-white m-8" do
      @template.content_tag :div, class: "bs-component" do
        @template.content_tag :div, class: "form-group" do
          
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


  def new_custom_text_area_field(name, title, *args)
    args[0] ||= {}
    args.first[:col] ||= "8"
    @template.content_tag :div, class: "mdl-cell--#{args.first[:col]}-col mdl-cell--#{args.first[:col]}-col-tablet ml-color--shades-white m-8" do
      (@template.content_tag :div, class: "bs-component" do
        @template.content_tag :div, class: "form-group" do
          str = @template.label("", "#{title}", class: "col-lg-3 control-label")
          str += @template.content_tag :div, class: "col-lg-8" do
            @template.content_tag :div, class: "bs-component" do 
              args[0] ||= {}
              args.first[:class] ||= "form-control textarea-grow"
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
    args.first[:col] ||= "8"
    @template.content_tag :div, class: "mdl-cell--#{args.first[:col]}-col mdl-cell--#{args.first[:col]}-col-tablet ml-color--shades-white allcp-form m-8" do
      @template.content_tag :div, class: "bs-component" do
        @template.content_tag :div, class: "form-group" do

          str = @template.label("", "#{title}", class: "col-lg-3 control-label")
          str += @template.content_tag :div, class: "col-lg-8" do
            @template.content_tag :div, class: "section" do
              @template.content_tag :label, class: "field file" do
                str = @template.content_tag :span ,"Choose File", class: "button btn-primary"
                str += file_field(name, id: id[:id])
                str += text_field("text_file_name", id: "1#{id[:id]}", :value => "", :read_only => true)
                str
              end  
            end
          end
            
        end    
      end
    end 
  end

end
