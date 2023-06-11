class ImportApi < ActiveRecord::Base
	validates :username, :password, :tablename, :pagenumber, presence: { :message => "This field is required." }

end
