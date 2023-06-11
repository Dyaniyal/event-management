class MyTravel < ActiveRecord::Base
  
  require 'set_mult_lng_data'
  require 'set_mult_lng_sequence'

  belongs_to :event
  belongs_to :invitee
  has_attached_file :attach_file, {}.merge(ATTACH_FILE_PATH)
  has_attached_file :attach_file_2, {}.merge(ATTACH_FILE_2_PATH)
  has_attached_file :attach_file_3, {}.merge(ATTACH_FILE_3_PATH)
  has_attached_file :attach_file_4, {}.merge(ATTACH_FILE_4_PATH)
  has_attached_file :attach_file_5, {}.merge(ATTACH_FILE_5_PATH)

  validates_attachment :attach_file,:attach_file_2,:attach_file_3,:attach_file_4,:attach_file_5, size: { in: 0..10.megabytes, :message => "upload file upto 10 mb" }
  #do_not_validate_attachment_file_type :attach_file
  validates :invitee_id,:attach_file_1_name, presence: { :message => "This field is required." }
  validates_attachment_presence :attach_file, :message => "This field is required." 
  validates_uniqueness_of :invitee_id, :message => "This Invitee is already Use." 
  validates_attachment_content_type :attach_file,:attach_file_2,:attach_file_3,:attach_file_4,:attach_file_5, :content_type => ["application/pdf"],:message => "please select valid format."
  validates_length_of :comment_box, :maximum => 100 , :message => "Comment is upto 100 characters only." 
  
  after_save :update_last_updated_model
  before_save :rename_attach_file_1_name,:rename_attach_file_2_name,:rename_attach_file_3_name,:rename_attach_file_4_name,:rename_attach_file_5_name
  after_create :update_multi_lng_model_data 
  after_destroy :remove_multi_lng_event_data

  def remove_multi_lng_event_data
    if self.parent_id.blank?
      SetMultLngSequence.remve_mlt_lng_data(self) # e.g remove sponsor of multilingual events if parent sponsor delete.
    end  
  end 
  
  def update_multi_lng_model_data
    if self.parent_id.blank?
      SetMultLngData.set_model_details(self)
    end 
  end  

  def update_last_updated_model
    LastUpdatedModel.update_record(self.class.name)
  end

	def attached_url
    self.attach_file.present? ? self.attach_file.url : ''
	end
  def attached_url_2
    self.attach_file_2.present? ? self.attach_file_2.url : ''
  end
  def attached_url_3
    self.attach_file_3.present? ? self.attach_file_3.url : ''
  end
  def attached_url_4
    self.attach_file_4.present? ? self.attach_file_4.url : '' 
  end
  def attached_url_5
    self.attach_file_5.present? ? self.attach_file_5.url : ''
  end

  def attachment_type
    file_type = self.attach_file_content_type.split("/").last rescue ""
    file_type
  end

  def Invitee_email
    self.invitee_id.present? ? Invitee.find_by_id(self.invitee_id).email : ''
  end
  def File_Name_1
    self.attach_file_1_name.present? ? self.attach_file_1_name : ''
  end
  def File_1_URL
    self.attach_file.present? ? self.attach_file.url : ''
  end
  def File_Name_2
    self.attach_file_2_name.present? ? self.attach_file_2_name : ''
  end
  def File_2_URL
    self.attach_file_2.present? ? self.attach_file_2.url : ''
  end
  def File_Name_3
    self.attach_file_3_name.present? ? self.attach_file_3_name : ''
  end
  def File_3_URL
    self.attach_file_3.present? ? self.attach_file_3.url : ''
  end
  def File_Name_4
    self.attach_file_4_name.present? ? self.attach_file_4_name : ''
  end
  def File_4_URL
    self.attach_file_4.present? ? self.attach_file_4.url : '' 
  end
  def File_Name_5
    self.attach_file_5_name.present? ? self.attach_file_5_name : '' 
  end
  def File_5_URL
    self.attach_file_5.present? ? self.attach_file_5.url : ''
  end
  def Comment_box
    self.comment_box.present? ? self.comment_box : ''
  end

  def rename_attach_file_1_name
    if (self.attach_file_updated_at_changed? and self.attach_file_file_name.present?)
      extension = File.extname(attach_file_file_name).downcase
      self.attach_file_file_name = "#{Time.now.to_i.to_s}_1#{extension}"
    end
  end
  def rename_attach_file_2_name
    if (self.attach_file_2_updated_at_changed? and self.attach_file_2_file_name.present?)
      extension = File.extname(attach_file_2_file_name).downcase
      self.attach_file_2_file_name = "#{Time.now.to_i.to_s}_2#{extension}"
    end
  end
  def rename_attach_file_3_name
    if (self.attach_file_3_updated_at_changed? and self.attach_file_3_file_name.present?)
      extension = File.extname(attach_file_3_file_name).downcase
      self.attach_file_3_file_name = "#{Time.now.to_i.to_s}_3#{extension}"
    end
  end
  def rename_attach_file_4_name
    if (self.attach_file_4_updated_at_changed? and self.attach_file_4_file_name.present?)
      extension = File.extname(attach_file_4_file_name).downcase
      self.attach_file_4_file_name = "#{Time.now.to_i.to_s}_4#{extension}"
    end
  end
  def rename_attach_file_5_name
    if (self.attach_file_5_updated_at_changed? and self.attach_file_5_file_name.present?)
      extension = File.extname(attach_file_5_file_name).downcase
      self.attach_file_5_file_name = "#{Time.now.to_i.to_s}_5#{extension}"
    end
  end
end
