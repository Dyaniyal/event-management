desc 'pass invitee token/key for tata event which not belongs to any event'
namespace :invitee_for_tata_acess_token do
  task set_invitee: :environment do
    invitee = Invitee.find_by_email("tata_default_token@previewapp.com")
    if invitee.blank?
      invitee = Invitee.create(name_of_the_invitee: "tata_acess_token_invitee", email: "tata_default_token@previewapp.com", password: "tatainvitee", invitee_password: "tatainvitee", :first_name => 'tata', :last_name => 'Invitee')
    end
  end
end
#rake invitee_for_tata_acess_token:set_invitee