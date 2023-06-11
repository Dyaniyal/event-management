class OnsiteAccessibleColumn < ActiveRecord::Base
  belongs_to :events
  serialize :accessible_attribute

  scope :selected_columns, -> { first.accessible_attribute.keys if first.try(:accessible_attribute) }
  scope :selected_values, -> { first.accessible_attribute.values.flatten if first.try(:accessible_attribute) }

end
