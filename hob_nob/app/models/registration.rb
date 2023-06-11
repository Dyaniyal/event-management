class Registration < ActiveRecord::Base
  
  require 'set_mult_lng_data'
  
  serialize :field1
  serialize :field2
  serialize :field3
  serialize :field4
  serialize :field5
  serialize :field6
  serialize :field7
  serialize :field8
  serialize :field9
  serialize :field10
  serialize :field11
  serialize :field12
  serialize :field13
  serialize :field14
  serialize :field15
  serialize :field16
  serialize :field17
  serialize :field18
  serialize :field19
  serialize :field20
  serialize :field21
  serialize :field22
  serialize :field23
  serialize :field24
  serialize :field25
  serialize :field26
  serialize :field27
  serialize :field28
  serialize :field29
  serialize :field30

  belongs_to :event
  has_many :user_registrations
  
  attr_accessor :label,:option_type,:validation_type,:option_1,:option_2,:option_3,:option_4,:option_5,:option_6,:option_7,:option_8,:option_9,:option_10,:mandatory_field,:text_box_required_after_options, :db_map_column_name, :invitee_map_column_name,:between_text, :single_check_box_default
  validates :email_field, presence: { :message => "This field is required." }
  validate :mandate_field_check,:check_radio_button_value_present#,:mandate_single_check_field
  after_save :update_last_updated_model
  after_create :update_multi_lng_model_data 

  default_scope { order('created_at desc') }

  def update_multi_lng_model_data
    if self.parent_id.blank?
      SetMultLngData.set_model_details(self)
    end 
  end  

  def mandate_field_check
    field = self.field1
      if field[:label].blank? or field[:option_type].blank? or field[:validation_type].blank? or field[:option_1].blank? or field[:option_2].blank?
        errors.add(:label, "This field is required.") if field[:label].blank?
        errors.add(:option_type, "This field is required.") if field[:option_type].blank?
        # errors.add('field1[validation_type]', "This field is required.") if (field[:validation_type].blank? and (["Text Box","Text Area"].include?(field[:option_type])))
        errors.add('field1[option_1]', "This field is required.") if (["Radio Button","Check Box","Drop-Down list"].include?(field[:option_type]) and field[:option_1].blank?)
        errors.add('field1[option_2]', "This field is required.") if (["Radio Button","Check Box","Drop-Down list"].include?(field[:option_type]) and field[:option_2].blank?)
        # errors.add('field1[text_box_required_after_options]', "This field is required.") if (["Radio Button","Check Box","Drop-Down list"].include?(field[:option_type]) and field[:text_box_required_after_options].blank?)
    end
  end
  def mandate_single_check_field
    (2..20).each do |i|
      field = self["field#{i}"]
      if field[:label].present? and field[:option_type].present? and ["Single Check Box"].include?(field[:option_type])
        errors.add("field#{i}[option]", "This field is required.") if ((["Single Check Box"].include?(field[:option_type])) and field[:option].blank?)
      end
    end
  end

  def selected_columns
    self.attributes.except('id', 'created_at', 'updated_at', 'event_id', 'custom_source_code').map{|k, v| (v.present? and v['label'].present?)? k : nil}.compact
  end

  def timestamp
    (self.created_at + self.event.timezone_offset.to_i.seconds).strftime("%d/%m/%Y %T")
  end

  def update_last_updated_model
    LastUpdatedModel.update_record(self.class.name)
  end
  
  def selected_column_values
    excluded_fields.map{|k, v| (v.present? and v['label'].present?) ? v['label'] : nil}.compact
  end

  def check_radio_button_value_present
    # fields = self
    (2..20).each do |i|
      field = self["field#{i}"]
      if field[:label].present? and field[:option_type].present? and ["Radio Button","Check Box","Drop-Down list"].include?(field[:option_type])
        errors.add("field#{i}[option_1]", "This field is required.") if ((["Radio Button","Check Box","Drop-Down list"].include?(field[:option_type])) and field[:option_1].blank?)
        errors.add("field#{i}[option_2]", "This field is required.") if ((["Radio Button","Check Box","Drop-Down list"].include?(field[:option_type])) and field[:option_2].blank?)
      end
    end
  end
  def self.get_columns(event)
    event.registrations.first.attributes.except('id', 'created_at', 'updated_at', 'event_id', 'custom_css','custom_js', 'custom_source_code','email_field','parent_id').map{|key, value| (value['label'].present? and value['option_type'].present?) ? [key,value] : nil}.compact!
  end

  def column_match_for_badge
   self.attributes.except('id', 'created_at', 'updated_at', 'event_id', 'custom_source_code','custom_css','custom_js','custom_source_code','email_field','parent_id','multi_lng_parent_id','language_updated').map{|k, v| (v.present? and v['label'].present?)? [ v['label'], k] : nil}.compact
  end

  def visible_fields_onsite
    attributes.keep_if { |key, value| event.onsite_accessible_columns.selected_columns.include? key }
  end

  def excluded_fields
    attributes.except('id', 'created_at', 'updated_at', 'event_id','custom_css','custom_js','custom_source_code')
  end

  def clickable_fields
    excluded_fields.map do |k, v|
      v['label'] if (v.present? and v['label'].present? and (v['option_type'].in? ['Check Box', 'Radio Button', 'Drop-Down list']))
    end.compact
  end

  def countable_option_fields(question)
    excluded_fields.map do |k, v|
      if (v.present? and (v['option_type'].in? ['Check Box', 'Radio Button', 'Drop-Down list']) and v['label'] == question)
        [*'option_1'..'option_10'].map do |option|
          attributes[k][option] if attributes[k][option].present?
        end
      end
    end.flatten.compact
  end

end
