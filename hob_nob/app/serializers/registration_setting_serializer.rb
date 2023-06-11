class RegistrationSettingSerializer < ActiveModel::Serializer
  
  def attributes 
  	data = super
    data[:id] = object.id
    data[:external_reg] = object.external_reg
    data[:reg_url] = object.reg_url
    data[:reg_surl] = object.reg_surl
    data[:external_login] = object.external_login
    data[:login_url] = object.login_url
    data[:login_surl] = object.login_surl
    data[:forget_pass_url] = object.forget_pass_url
    data[:forget_pass_surl] = object.forget_pass_surl
    data[:created_at] = object.created_at
    data[:updated_at] = object.updated_at
    data[:event_id] = object.event_id
    data[:registration] = object.registration
    data[:login] = object.login
    data[:response_type] = object.response_type
    data[:external_reg_url] = object.external_reg_url
    data[:external_reg_surl] = object.external_reg_surl
    data[:external_login_url] = object.external_login_url
    data[:external_login_surl] = object.external_login_surl
    data[:template] = object.template
    data[:on_mobile_app] = object.on_mobile_app
    data[:start_date] = object.start_date
    data[:end_date] = object.end_date
    data[:auto_approved] = object.auto_approved
    data[:parent_id] = object.parent_id
    data[:auto_rejected] = object.auto_rejected
    data[:auto_rejected_domain_validation] = object.auto_rejected_domain_validation
    data[:auto_approved_domain_validation] = object.auto_approved_domain_validation
    data[:target_registration] = object.target_registration
    data[:target_attendees] = object.target_attendees
    data[:multi_lng_parent_id] = object.multi_lng_parent_id
    data[:language_updated] = object.language_updated
    Hash[*data.map{|k, v| v.nil? ? [k, v || ""] : [k, v]}.flatten]
	end
end
