class MyProfile < ActiveRecord::Base
	
	require 'set_mult_lng_data'
  serialize :enabled_attr, Hash
  DISPLAY_FIELD_NAME = {"name_of_the_invitee"=>"Full Name", "email"=>"Email", "first_name"=>"First Name", "last_name"=>"Last Name", "company_name"=>"Company Name", "designation"=>"Designation", "mobile_no"=>"Mobile No", "website"=>"Website", "street"=>"Street", "locality"=>"Locality", "location"=>"Location", "country"=>"Country", "about"=>"About", "interested_topics"=>"Interested Topics", "twitter_id"=>"Twitter Id", "facebook_id"=>"Facebook Id", "google_id"=>"Google Id", "linkedin_id"=>"Linkedin Id", "remark"=>'Remark','instagram_id'=>'Instagram'}
  belongs_to :event
  before_create :set_default_enabled_attr
  after_create :update_multi_lng_model_data 
  

  def update_multi_lng_model_data
    if self.parent_id.blank?
      SetMultLngData.set_model_details(self)
    end 
  end
    
  def set_default_enabled_attr
    self.enabled_attr = {"name_of_the_invitee"=>"yes", "email"=>"yes", "first_name"=>"yes", "last_name"=>"yes", "company_name"=>"yes", "designation"=>'no', "mobile_no"=>'no', "website"=>'no', "street"=>'no', "locality"=>'no', "location"=>'no', "country"=>'no', "about"=>'no', "interested_topics"=>'yes', "twitter_id"=>'no', "facebook_id"=>'no', "google_id"=>'no', "linkedin_id"=>'no', "remark"=>'no','instagram_id'=>'no'}
    self
  end
  def get_column_names
    hsh = DISPLAY_FIELD_NAME
    hsh.merge!('attr1' => self.attr1) if self.attr1.present?
    hsh.merge!('attr2' => self.attr2) if self.attr2.present?
    hsh.merge!('attr3' => self.attr3) if self.attr3.present?
    hsh.merge!('attr4' => self.attr4) if self.attr4.present?
    hsh.merge!('attr5' => self.attr5) if self.attr5.present?
    hsh
  end
  def self.get_default_grouping_fields(event)
    my_profile = event.my_profiles.last
    arr = my_profile.enabled_attr rescue {"name_of_the_invitee"=>"yes", "email"=>"yes", "first_name"=>"yes", "last_name"=>"yes", "company_name"=>"yes", "designation"=>'no', "mobile_no"=>'no', "website"=>'no', "street"=>'no', "locality"=>'no', "location"=>'no', "country"=>'yes', "about"=>'no', "interested_topics"=>'no', "twitter_id"=>'no', "facebook_id"=>'no', "google_id"=>'no', "linkedin_id"=>'no', "remark"=>'no',"instagram_id"=>'no'}
    if arr.include? nil
      arr = arr.compact
    else
      arr
    end
    ((my_profile.present? and my_profile.attr1.present?) ? (my_profile.enabled_attr['attr1'] == 'yes' ? arr.merge!('attr1' => 'yes') : arr.merge!('attr1' => 'no')) : '')
    ((my_profile.present? and my_profile.attr2.present?) ? (my_profile.enabled_attr['attr2'] == 'yes' ? arr.merge!('attr2' => 'yes') : arr.merge!('attr2' => 'no')) : '')
    ((my_profile.present? and my_profile.attr3.present?) ? (my_profile.enabled_attr['attr3'] == 'yes' ? arr.merge!('attr3' => 'yes') : arr.merge!('attr3' => 'no')) : '')
    ((my_profile.present? and my_profile.attr4.present?) ? (my_profile.enabled_attr['attr4'] == 'yes' ? arr.merge!('attr4' => 'yes') : arr.merge!('attr4' => 'no')) : '')
    ((my_profile.present? and my_profile.attr5.present?) ? (my_profile.enabled_attr['attr5'] == 'yes' ? arr.merge!('attr5' => 'yes') : arr.merge!('attr5' => 'no')) : '')
    arr
  end
  def self.get_my_profile(event)
    my_profile = event.my_profiles.last || event.my_profiles.build(:enabled_attr => {"name_of_the_invitee"=>"yes", "email"=>"yes", "first_name"=>"yes", "last_name"=>"yes", "company_name"=>"yes", "designation"=>'no', "mobile_no"=>'no', "website"=>'no', "street"=>'no', "locality"=>'no', "location"=>'no', "country"=>'no', "about"=>'no', "interested_topics"=>'no', "twitter_id"=>'no', "facebook_id"=>'no', "google_id"=>'no', "linkedin_id"=>'no', "remark"=>'no','instagram_id'=>'no'})
    my_profile
  end
  def set_enabled_attr(params)
    hsh = {}
    if params[:step] == 'first'
      self.assign_attributes(:attr1 => params[:my_profile][:attr1]) if params[:my_profile][:attr1].present?
      self.assign_attributes(:attr2 => params[:my_profile][:attr2]) if params[:my_profile][:attr2].present?
      self.assign_attributes(:attr3 => params[:my_profile][:attr3]) if params[:my_profile][:attr3].present?
      self.assign_attributes(:attr4 => params[:my_profile][:attr4]) if params[:my_profile][:attr4].present?
      self.assign_attributes(:attr5 => params[:my_profile][:attr5]) if params[:my_profile][:attr5].present?
    end
    hsh = self.enabled_attr
    if true#hsh.blank?
      ["name_of_the_invitee", "email", "first_name", "last_name", "company_name", "designation", "mobile_no", "website", "street", "locality", "location", "country", "about", "interested_topics", "twitter_id", "facebook_id", "google_id", "linkedin_id", "remark","instagram_id"].map{|key| hsh[key] = params[:my_profile][:enabled_attr][key].present? ? params[:my_profile][:enabled_attr][key] : 'no'} if params[:my_profile][:enabled_attr].present?
    end
    (self.attr1.present? ? (params[:my_profile][:enabled_attr].present? and params[:my_profile][:enabled_attr][:attr1] == 'yes' ? hsh.merge!('attr1' => 'yes') : hsh.merge!('attr1' => 'no')) : '')
    (self.attr2.present? ? (params[:my_profile][:enabled_attr].present? and params[:my_profile][:enabled_attr][:attr2] == 'yes' ? hsh.merge!('attr2' => 'yes') : hsh.merge!('attr2' => 'no')) : '')
    (self.attr3.present? ? (params[:my_profile][:enabled_attr].present? and params[:my_profile][:enabled_attr][:attr3] == 'yes' ? hsh.merge!('attr3' => 'yes') : hsh.merge!('attr3' => 'no')) : '')
    (self.attr4.present? ? (params[:my_profile][:enabled_attr].present? and params[:my_profile][:enabled_attr][:attr4] == 'yes' ? hsh.merge!('attr4' => 'yes') : hsh.merge!('attr4' => 'no')) : '')
    (self.attr5.present? ? (params[:my_profile][:enabled_attr].present? and params[:my_profile][:enabled_attr][:attr5] == 'yes' ? hsh.merge!('attr5' => 'yes') : hsh.merge!('attr5' => 'no')) : '')
    # hsh.merge!('attr2' => 'yes') if self.attr2.present? and params[:my_profile][:enabled_attr].present? and params[:my_profile][:enabled_attr][:attr2] == 'yes'
    # hsh.merge!('attr3' => 'yes') if self.attr3.present? and params[:my_profile][:enabled_attr].present? and params[:my_profile][:enabled_attr][:attr3] == 'yes'
    # hsh.merge!('attr4' => 'yes') if self.attr4.present? and params[:my_profile][:enabled_attr].present? and params[:my_profile][:enabled_attr][:attr4] == 'yes'
    # hsh.merge!('attr5' => 'yes') if self.attr5.present? and params[:my_profile][:enabled_attr].present? and params[:my_profile][:enabled_attr][:attr5] == 'yes'
    self.assign_attributes(:enabled_attr => hsh)
    self
  end
end
