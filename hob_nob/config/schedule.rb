# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
set :output, "log/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
#every 1.minute do
#  runner "Notification.push_notification_time_basis", :environment => :staging
#end

# Learn more: http://github.com/javan/whenever

# every 30.minutes do
#   runner "User.change_status_for_super_admin", :environment => :production
# end

 every 2.minutes do
   runner "Notification.send_push_notifications", :environment => :production
 end

# every 5.minutes do
#   runner "Event.set_event_category", :environment => :production
# end

# every 1.day, at: '00:01 am' do
#   runner "InviteeStructure.destroy_expired_invitee_datums", environment: :production
# end

	# every 3.minutes do
	# 	runner "ExcelImportInviteeData.process_import_invitee_data", environment: :production
	# end

#every 5.minutes do 
  #runner "Edm.send_push_notifications", :environment => :production
#end

every 5.minutes do
  runner "Event.set_event_category", :environment => :production
end

every 1.day, at: '00:01 am' do
  runner "InviteeStructure.destroy_expired_invitee_datums", environment: :production
end

every 3.minutes do
	runner "ExcelImportInviteeData.process_import_invitee_data", environment: :production
end
