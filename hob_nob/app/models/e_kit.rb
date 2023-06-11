class EKit < ActiveRecord::Base

  require 'set_mult_lng_sequence'
  require 'set_mult_lng_data'

  serialize :group_ids, Array
  acts_as_taggable
  belongs_to :event
  belongs_to :agenda
  belongs_to :sponsor
  has_many :favorites, as: :favoritable, :dependent => :destroy
	has_attached_file :attachment,{}.merge(EKIT_IMAGE_PATH)

  validates_attachment :attachment, size: { in: 0..10.megabytes, :message => "upload file upto 10 mb" }#, :if => :pdf_attached?
  do_not_validate_attachment_file_type :attachment
  validates_attachment_presence :attachment, :message => "This field is required." 
  validates :name, presence: { :message => "This field is required." }
  #validates_attachment_content_type :attachment, :content_type => %w(application/zip application/msword application/vnd.ms-office application/vnd.ms-excel application/vnd.openxmlformats-officedocument.spreadsheetml.sheet application/xls application/xlsx application/pdf)
  after_save :update_last_updated_model
  after_save :update_folder_cache
  validate :check_attachment_type
  validate :check_folder
  before_save :rename_attachment_name
  after_create :update_multi_lng_model_data
  after_destroy :remove_multi_lng_event_data
  default_scope { order('created_at desc') }
  
  def remove_multi_lng_event_data
    if self.parent_id.blank?
      SetMultLngSequence.remve_mlt_lng_data(self) # e.g remove e_kit of multilingual events if parent e_kit delete.
    end
  end
  
  def update_multi_lng_model_data
    if self.parent_id.blank?
      SetMultLngData.set_model_details(self)
    end 
  end  

  def check_attachment_type
    hsh = {'jpeg' => 'jpg', 'jpg' => 'jpg', 'doc' => 'docx', 'docb' => 'docb', 'docm' => 'docx', 'dotm' => 'docx', 'docx' => 'docx', 'xls' => 'xls', 'xlsx' => 'xlsx', 'pdf' => 'pdf', 'ppt' => 'ppt', 'pptx' => 'pptx', 'msword' => 'docx', 'vnd.ms-powerpoint' => 'ppt', 'vnd.openxmlformats-officedocument.presentationml.presentation' => 'ppt', 'octet-stream' => 'xls', 'vnd.openxmlformats-officedocument.spreadsheetml.sheet' => 'xls', 'vnd.ms-excel' => 'xls', 'vnd.openxmlformats-officedocument.wordprocessingml.document' => 'docx'}
    file_type = self.attachment_content_type.split("/").last rescue ""
    if hsh.key?(file_type) == false
      errors.add(:attachment, "Please select valid file format.")
    end
  end

  def update_folder_cache
    self.update_column(:folder_name_cache, (self.tags.last.name rescue ''))
  end

  def check_folder
    errors.add(:sub_folder, "Can't create sub-folder without folder.") if self.tag_list.blank? and self.sub_folder.present? and self.parent_id.blank?
  end

  def update_last_updated_model
    LastUpdatedModel.update_record(self.class.name)
  end

	def pdf_attached?
	  self.attachment.file?
	end

  def self.search_tag(params,tags)
    keyword = params[:search][:keyword]
     tags = tags.where("name like (?) ", "%#{keyword}%") if keyword.present?
    # tags = EKit.tagged_with(tags.first.name)
    tags
  end 

  def self.search(params,e_kits)
    keyword = params[:search][:keyword]
    e_kits = e_kits.select{|e_kit| e_kit.name.include?("#{keyword}")} if keyword.present?
    e_kits
  end

  def attachment_url
    if self.parent_id.present? and not self.attachment.exists?
      parent = EKit.find(self.parent_id)
      parent.attachment.url
    else
      self.attachment.url rescue nil
    end
  end

  def folder_name
    folder_name_cache
  end

  def attachment_type
    hsh = {'png' => 'png', 'jpeg' => 'jpg', 'jpg' => 'jpg', 'doc' => 'docx', 'docm' => 'docx', 'docx' => 'docx', 'xls' => 'xls', 'xlsx' => 'xls', 'pdf' => 'pdf', 'ppt' => 'ppt', 'msword' => 'docx', 'vnd.ms-powerpoint' => 'ppt', 'vnd.openxmlformats-officedocument.presentationml.presentation' => 'ppt', 'vnd.openxmlformats-officedocument.spreadsheetml.sheet' => 'xls', 'vnd.ms-excel' => 'xls'}
    file_type = self.attachment_content_type.split("/").last rescue ""
    file_type = self.attachment_file_name.split(".").last if file_type.to_s == "octet-stream"
    file_type = hsh[file_type.downcase].present? ? hsh[file_type.downcase] : file_type
    file_type
  end
  
  def self.get_e_kits(event)
    tags = event.first.e_kits.tag_counts_on(:tags) rescue nil
    data = []
    value = {}
    value1 = {}
    arr_list = []
    sub_folder_arr = []
    tags.each do |tag|
      ekits = EKit.tagged_with(tag.name).where(:event_id => event.first.id)
      flag = false
      ekits.map{|x| flag = true if (x.sub_folder.present? and x.sub_folder != "")}
      value["type"], value["tag"], value["sub_folder_available"] = "folder", tag.name, "#{flag}"
      s_folder_name = ''
      ekits.group(:sub_folder).each do |ekit|
        if ekit.sub_folder.present?
          value1["subfolder_type"], value1["subfolder_tag"] = "sub_folder", ekit.sub_folder
          value1["subfolder_list"] = ekits.where("sub_folder = ?", ekit.sub_folder).as_json(:only => [:id,:event_id, :name, :created_at, :updated_at, :agenda_id, :sponsor_id,:show_e_kit_feature], :methods => [:attachment_url,:attachment_type ]) rescue nil
          sub_folder_arr << value1
          value1 = {}
          value["sub_folder"] = sub_folder_arr
        else
          value["list"] = ekits.where("sub_folder = ? or sub_folder is null",'').as_json(:only => [:id,:event_id, :name, :created_at, :updated_at, :agenda_id, :sponsor_id,:show_e_kit_feature], :methods => [:attachment_url,:attachment_type ]) rescue nil
        end
      end
      data << value rescue nil
      value = {}      
      value1 = {}
      arr_list = []
      sub_folder_arr = []
    end
    event.first.e_kits.each do |e_kit|
      if (e_kit.tags.count == 0) 
        value["type"], value["tag"], value["sub_folder_available"] = "non_folder", '', "false"
        value["list"] = [e_kit.as_json(:only => [:id,:event_id, :name, :created_at, :updated_at, :agenda_id, :sponsor_id], :methods => [:attachment_url,:attachment_type])] rescue nil
        data << value rescue nil
        value = {}
      end
    end
    data  
  end

  def self.get_e_kits_v4(event,current_user)
    tags = event.first.e_kits.reorder(created_at: :asc).map(&:tags).flatten.uniq rescue nil
    data = []
    value = {}
    tags.each do |tag|
      value["type"], value["tag"] = "folder", tag.name
      value["list"] = EKit.tagged_with(tag.name).where(:event_id => event.first.id).as_json(:only => [:id,:event_id, :name, :created_at, :updated_at, :attachment_updated_at, :agenda_id, :sponsor_id,:show_e_kit_feature, :sub_folder], :methods => [:attachment_url,:attachment_type, :feature_invitee_ids]) rescue nil
      value["list"] = value["list"].map{|x| ((x["show_e_kit_feature"] == "group" and x["feature_invitee_ids"].include? current_user.id.to_s) or x["show_e_kit_feature"] != "group") ? x :  nil}.compact if current_user.present?
      value["list"] = [] if value["list"].blank? or value["list"] == [""]
      data << value rescue nil
      value = {}
    end
    event.first.e_kits.each do |e_kit|
      if (e_kit.tags.count == 0)
        value["type"], value["tag"] = "non_folder", ""
        value["list"] = [e_kit.as_json(:only => [:id,:event_id, :name, :created_at, :updated_at, :attachment_updated_at, :agenda_id, :sponsor_id, :show_e_kit_feature, :sub_folder], :methods => [:attachment_url,:attachment_type, :feature_invitee_ids])] rescue []
        value["list"] = value["list"].map{|x| ((x["show_e_kit_feature"] == "group" and x["feature_invitee_ids"].include? current_user.id.to_s) or x["show_e_kit_feature"] != "group") ? x : nil}.compact if current_user.present?
        value["list"] = [] if value["list"].blank? or value["list"] == [""]
        data << value rescue nil
        value = {}
      end
    end
    data  
  end

  # def self.get_e_kits_all_events(event_ids)
  #   tags = EKit.where(:event_id => event_ids).tag_counts_on(:tags) rescue []
  #   data = []
  #   value = {}
  #   tags.each do |tag|
  #     value["type"], value["tag"] = "folder", tag.name
  #     value["list"] = EKit.tagged_with(tag.name).where(:event_id => event_ids).as_json(:only => [:id,:event_id, :name, :created_at, :updated_at], :methods => [:attachment_url,:attachment_type ]) rescue nil
  #     data << value rescue nil
  #     value = {}
  #   end
  #   EKit.where(:event_id => event_ids).each do |e_kit|
  #     if (e_kit.tags.count == 0)
  #       value["type"], value["tag"] = "non_folder", ""
  #       value["list"] = [e_kit.as_json(:only => [:id,:event_id, :name, :created_at, :updated_at], :methods => [:attachment_url,:attachment_type])] rescue []
  #       data << value rescue nil
  #       value = {}
  #     end
  #   end
  #   data  
  # end

  def feature_invitee_ids
    InviteeGroup.where("id in (?)",self.group_ids).map{|x| x.get_invitee_ids}.flatten.join(",")
  end
  
  def self.get_e_kits_all_events(event_ids, start_event_date, end_event_date, latest_published_event_ids)
    if latest_published_event_ids.present?
      tags = EKit.where("(event_id IN (?) and updated_at between ? and ?) or event_id IN (?)", event_ids, start_event_date, end_event_date, latest_published_event_ids).tag_counts_on(:tags)
    else
      tags = EKit.where(:event_id => event_ids, :updated_at => start_event_date..end_event_date).tag_counts_on(:tags)
    end
    data = []
    value = {}
    value1 = {}
    arr_list = []
    sub_folder_arr = []
    tags.each do |tag|
      ekits = EKit.tagged_with(tag.name).where(:event_id => event_ids)
      flag = false
      ekits.map{|x| flag = true if (x.sub_folder.present? and x.sub_folder != "")}
      value["type"], value["tag"], value["sub_folder_available"] = "folder", tag.name, "#{flag}"
      s_folder_name = ''
      ekits.group(:sub_folder).each do |ekit|
        if ekit.sub_folder.present?
          value1["subfolder_type"], value1["subfolder_tag"] = "sub_folder", ekit.sub_folder
          value1["subfolder_list"] = ekits.where("sub_folder = ?", ekit.sub_folder).as_json(:only => [:id,:event_id, :name, :created_at, :updated_at, :agenda_id, :sponsor_id,:show_e_kit_feature], :methods => [:attachment_url,:attachment_type ]) rescue nil
          sub_folder_arr << value1
          value1 = {}
          value["sub_folder"] = sub_folder_arr
        else
          value["list"] = ekits.where("sub_folder = ? or sub_folder is null",'').as_json(:only => [:id,:event_id, :name, :created_at, :updated_at, :agenda_id, :sponsor_id,:show_e_kit_feature], :methods => [:attachment_url,:attachment_type ]) rescue nil
        end
      end
      data << value rescue nil
      value = {}      
      value1 = {}
      arr_list = []
      sub_folder_arr = []
    end
    EKit.where(:event_id => event_ids, :updated_at => start_event_date..end_event_date).each do |e_kit|
      if (e_kit.tags.count == 0)
        value["type"], value["tag"], value["sub_folder_available"] = "non_folder", '', "false"
        value["list"] = [e_kit.as_json(:only => [:id,:event_id, :name, :created_at, :updated_at, :attachment_updated_at, :agenda_id, :sponsor_id,:show_e_kit_feature], :methods => [:attachment_url,:attachment_type])] rescue nil
        data << value rescue nil
        value = {}
      end
    end
    data  
  end

  def self.get_e_kits_all_events_v4(event_ids, start_event_date, end_event_date, latest_published_event_ids, current_user)
    if latest_published_event_ids.present?
      tags = EKit.where("(event_id IN (?) and updated_at between ? and ?) or event_id IN (?)", event_ids, start_event_date, end_event_date, latest_published_event_ids).tag_counts_on(:tags)
    else
      tags = EKit.where(:event_id => event_ids, :updated_at => start_event_date..end_event_date).tag_counts_on(:tags) rescue []
    end
    data = []
    value = {}
    tags.each do |tag|
      value["type"], value["tag"] = "folder", tag.name
      value["list"] = EKit.tagged_with(tag.name).where(:event_id => event_ids, :updated_at => start_event_date..end_event_date).as_json(:only => [:id,:event_id, :name, :created_at, :updated_at, :attachment_updated_at, :agenda_id, :sponsor_id, :show_e_kit_feature, :sub_folder], :methods => [:attachment_url, :attachment_type, :feature_invitee_ids]) rescue []
      value["list"] = value["list"].map{|x| ((x["show_e_kit_feature"] == "group" and x["feature_invitee_ids"].include? current_user.id.to_s) or x["show_e_kit_feature"] != "group") ? x : nil}.compact if current_user.present?
      value["list"] = [] if value["list"].blank? or value["list"] == [""]
      data << value rescue nil
      value = {}
    end
    EKit.where(:event_id => event_ids, :updated_at => start_event_date..end_event_date).each do |e_kit|
      if (e_kit.tags.count == 0)
        value["type"], value["tag"] = "non_folder", ""
        value["list"] = [e_kit.as_json(:only => [:id,:event_id, :name, :created_at, :updated_at, :attachment_updated_at, :agenda_id, :sponsor_id,:show_e_kit_feature, :sub_folder], :methods => [:attachment_url,:attachment_type, :feature_invitee_ids])] rescue []
        value["list"] = value["list"].map{|x| ((x["show_e_kit_feature"] == "group" and x["feature_invitee_ids"].include? current_user.id.to_s) or x["show_e_kit_feature"] != "group") ? x : nil}.compact if current_user.present?
        value["list"] = [] if value["list"].blank? or value["list"] == [""]
        data << value rescue nil
        value = {}
      end
    end
    data  
  end

  def get_tag_name
    event = self.event 
    tags = event.e_kits.tag_counts_on(:tags)
    tag_name = "-"
    tags.each do |tag|
      e_kits = event.e_kits.tagged_with(tag.name)
      tag_name = tag.name if e_kits.include?(self)
    end
    tag_name 
  end

  def rename_attachment_name
    if (self.attachment_file_name_changed? and self.attachment_file_name.present?)
      extension = File.extname(attachment_file_name).downcase
      self.attachment_file_name = "#{Time.now.to_i.to_s}#{extension}"
    end
  end
end
