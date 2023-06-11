module Admin::EdmsHelper

  def links_to_existing_reg_edm(edm_id, type)
    links = []
    links << link_to('Edit', edit_admin_event_campaign_edm_path(event_id: @event.id, campaign_id: 0, id: edm_id, update_mail: true,mail_to: type), class: 'mdl-menu__item')
    links << link_to(Edm.find(edm_id).active ? 'Deactivate' : 'Activate', admin_event_campaign_edm_path(id: edm_id, toggle: true), data: { confirm: 'Are you sure?' }, method: :put, class: 'mdl-menu__item')
    links << link_to('Statistics', admin_event_campaign_details_path(event_id: @event.id, edm_id: edm_id), class: 'mdl-menu__item')
    links
  end

  def links_to_new_reg_edm(edm_id, type)
    link_to 'New', new_admin_event_campaign_edm_path(event_id: @event.id, campaign_id: 0, auto_emailer: true, mail_to: type), class: 'mdl-menu__item'
  end

  def hash_val(db_record)
    hash_val = { 'current_user' => @email }
    if @user_registration.present?
      if %w(approved confirmed).include?(@edm.mail_to) && @edm.show_qr_code == 'yes'
        hash_val.merge!('qr_code' => "<img src='#{db_record.qr_code.url}'>")
      end
      (1..30).to_a.reverse.inject(hash_val) { |m,e| m["field#{e}"] = db_record.send("field#{e}"); m }
    else
      (1..50).to_a.reverse.inject(hash_val) { |m,e| m["attr#{e}"] = db_record.send("attr#{e}"); m }
    end
  end

end