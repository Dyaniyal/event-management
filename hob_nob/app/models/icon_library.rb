class IconLibrary < ActiveRecord::Base
  belongs_to :user
  has_many :icons, :dependent => :destroy
  accepts_nested_attributes_for :icons

  validates :icon_library_name, presence:{ :message => "This field is required." } 
end
