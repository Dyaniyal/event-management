class TelecallerAccessibleColumn < ActiveRecord::Base
  belongs_to :events
  serialize :accessible_attribute
  validate :check_attr1_is_present

  def check_attr1_is_present
    errors.add(:accessible_attribute, "This field is required.") if self.accessible_attribute.blank?
  end
end
