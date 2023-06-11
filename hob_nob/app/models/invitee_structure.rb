class InviteeStructure < ActiveRecord::Base

  require 'set_mult_lng_data'

  belongs_to :event
  has_many :invitee_datum
  
  validates :event_id, :uniq_identifier, :presence => true
  validate :check_column_value_is_present
  validate :validate_expiry_date
  before_create :create_default_group
  after_create :update_multi_lng_model_data 

  default_scope { order('created_at desc') }

  def self.destroy_expired_invitee_datums
    having_expiry_dates = InviteeStructure.where('expiry_date < ?', Time.zone.today)
    if having_expiry_dates.present?
      having_expiry_dates.each do |invitee_structure|
        if invitee_structure.invitee_datum.present?
          invitee_structure.invitee_datum.map(&:destroy)
          puts "=========== InviteeDatum of InviteeStructure: #{invitee_structure.id} is destroyed ==========="
        end
      end
    end
  end

  def update_multi_lng_model_data
    if self.parent_id.blank?
      SetMultLngData.set_model_details(self)
    end 
  end  

  def method_missing method_name, *args
    attr_key = self.attributes.except('id', 'created_at', 'updated_at', 'event_id', 'uniq_identifier').map{|k, v| v.to_s.length > 0 && v.downcase == method_name.to_s ? k.downcase : nil}.compact!
    attr_value = self.invitee_datum.first.attributes[attr_key.first.to_s] rescue nil
    attr_value
  end

  def get_selected_column 
    attr_key = self.attributes.except('id', 'created_at', 'updated_at', 'event_id', 'uniq_identifier', 'email_field','mandate_attr1','mandate_attr2','mandate_attr3','mandate_attr4','mandate_attr5','mandate_attr6','mandate_attr7','mandate_attr8','mandate_attr9','mandate_attr10','mandate_attr11','mandate_attr12','mandate_attr13','mandate_attr14','mandate_attr15','mandate_attr16','mandate_attr17','mandate_attr18','mandate_attr19','mandate_attr20','mandate_attr21','mandate_attr22','mandate_attr23','mandate_attr24','mandate_attr25','mandate_attr26','mandate_attr27','mandate_attr28','mandate_attr29','mandate_attr30','parent_id','multi_lng_parent_id','language_updated').map{|k, v| v.to_s.length > 0 ? k.downcase : nil}.compact
  end

  def get_database_columns
    attr_key = self.attributes.except('id', 'created_at', 'updated_at', 'event_id', 'uniq_identifier', 'email_field','mandate_attr1','mandate_attr2','mandate_attr3','mandate_attr4','mandate_attr5','mandate_attr6','mandate_attr7','mandate_attr8','mandate_attr9','mandate_attr10','mandate_attr11','mandate_attr12','mandate_attr13','mandate_attr14','mandate_attr15','mandate_attr16','mandate_attr17','mandate_attr18','mandate_attr19','mandate_attr20','mandate_attr21','mandate_attr22','mandate_attr23','mandate_attr24','mandate_attr25','mandate_attr26','mandate_attr27','mandate_attr28','mandate_attr29','mandate_attr30','multi_lng_parent_id','language_updated').map{|k, v| v.to_s.length > 0 ? v.downcase : nil}.compact
  end

  def create_default_group
    if self.parent_id.blank?
      #Grouping.create(name: "Default Group", event_id: self.event_id)
      Grouping.create(name: "All Records", event_id: self.event_id)
    end
  end

  def check_invitee_data_present?
    InviteeDatum.where(:invitee_structure_id => self.id).present?
  end
  def selected_columns
    self.attributes.except('id', 'created_at', 'updated_at', 'event_id', 'custom_source_code').map{|k, v| (v.present?)? v : nil}.compact
  end
  def selected_column_values
    self.attributes.except('id', 'created_at', 'updated_at', 'event_id','custom_css','custom_js','custom_source_code').map{|k, v| (v.present? and v.present?) ? v : nil}.compact
  end

  def self.hide_destroy_link(event)
    users = User.joins(:roles).where('roles.resource_type = ? and resource_id = ? and roles.name NOT IN (?)', event.class.name, event.id, ['licensee_admin', 'client_admin', 'event_admin', 'moderator', 'db_manager']).uniq
    data = []
    for user in users
      grouping = Grouping.find_by_id(user.assign_grouping) 
      data << grouping if grouping.present?
    end
    return data
  end

  def check_column_value_is_present
    invitee_structure = self.attributes.except('id','attr1',"attr2","attr3","attr4","attr5","attr6","attr7","attr8","attr9","attr10","attr11","attr12","attr13","attr14","attr15","attr16","attr17","attr18","attr19","attr20","parent_id","created_at","updated_at","event_id","uniq_identifier","email_field")
    invitee_structure.each do |mandate_value|
      if invitee_structure.include?(mandate_value[0]) and invitee_structure[mandate_value[0]] == "yes" and self[mandate_value[0].gsub('mandate_',"")].blank?
        errors.add(mandate_value[0].gsub('mandate_',""), "this field is required.")
      end
    end
  end

  def validate_expiry_date
    if expiry_date.present? and expiry_date <= Date.today
      errors.add(:expiry_date, 'Please select a future Date')
    end
  end

end
