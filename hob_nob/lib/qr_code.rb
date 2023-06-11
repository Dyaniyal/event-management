require 'rubygems'
require 'vpim/vcard'
require 'rqrcode_png'


module QRCode
  
  # def find_objekt(klass_type, obj_id)
  #   klass_type.singularize.camelcase.constantize.where(:id => obj_id)
  # end

  def self.generate_qr_code(app_id, invitee_id)
    str = app_id.to_s + ',' + invitee_id.to_s

    qr = RQRCode::QRCode.new(str, :size => 2, :level => :l )
    png = qr.to_img
    png.resize(400, 400).save("public/qr_code/user#{app_id.to_s}_#{invitee_id}.png")
    z = File.open("public/qr_code/user#{app_id.to_s}_#{invitee_id}.png")#, 'wb') do |f|
    # self.qr_code = z
    # system "sudo rm public/user#{self.id}_#{self.email}.png"
    z
  end

  def self.generate_qr_code_for_registration(app_id, user_regi_id)
    str = app_id.to_s + ',' + user_regi_id.to_s + ',' + "user_registration" 
    qr = RQRCode::QRCode.new(str, :size => 4, :level => :h )
    png = qr.to_img
    png.resize(200, 200).save("public/qr_code/user_registration#{app_id.to_s}_#{user_regi_id}.png")
    z = File.open("public/qr_code/user_registration#{app_id.to_s}_#{user_regi_id}.png")#, 'wb') do |f|
    # self.qr_code = z
    # system "sudo rm public/user#{self.id}_#{self.email}.png"
    z
  end

  # def self.old_generate_qr_code(username, location, street, locality, country, mobile_no, email, website)
  #   card = Vpim::Vcard::Maker.make2 do |maker|
  #     maker.add_name do |name|
  #       name.prefix = ''
  #       name.given = username || ''
  #       #name.family = last_name
  #     end
  #     maker.add_addr do |addr|
  #       addr.preferred = true
  #       addr.location = location || ''
  #       addr.street = street || ''
  #       addr.locality = locality || ''
  #       addr.country = country || ''
  #     end
  #     maker.add_tel(mobile_no) if mobile_no.present?
  #     maker.add_email(email) { |e| e.location = 'internet' } if email.present?
  #     maker.add_url(website) { |e| e.location = 'internet' } if website.present?
  #   end
  #   str = card.to_s

  #   qr = RQRCode::QRCode.new(str, :size => 24, :level => :h )
  #   png = qr.to_img
  #   png.resize(200, 200).save("public/qr_code/user#{username}_#{email}.png")
  #   z = File.open("public/qr_code/user#{username}_#{email}.png")#, 'wb') do |f|
  #   # self.qr_code = z
  #   # system "sudo rm public/user#{self.id}_#{self.email}.png"
  #   z
  # end
end
