require 'rubygems'
require 'openssl'
require 'base64'

module TataLogin

  def self.validate_email_password(email, password)
    public_key_file = "#{Rails.root}/lib/publickey.pem"
    public_key =  OpenSSL::PKey::RSA.new(File.read(public_key_file))
    encrypted_email = Base64.encode64(public_key.public_encrypt(email))
    encrypted_password = Base64.encode64(public_key.public_encrypt(password))
    xmlString = "<?xml version='1.0' encoding='utf-8'?><soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'><soap:Header><TWAuthheader xmlns='https://www.tataworld.com/'><Username>Ea$93SsOtW@8</Username><Password>VtueZ1a02OBGUtrN2Qx!$$$$!KA==</Password></TWAuthheader></soap:Header><soap:Body><authencryptuserdet xmlns='https://www.tataworld.com/'><emailid>#{encrypted_email.gsub("\n","")}</emailid><pswrd>#{encrypted_password.gsub("\n","")}</pswrd></authencryptuserdet></soap:Body></soap:Envelope>"
    File.open("#{Rails.root}/public/external_login/#{email}_login_details.xml", 'w') do |file|
      file.write xmlString
    end
    str = `curl -X POST -H "Content-Type:text/xml" --header "SOAPAction:https://www.tataworld.com/authencryptuserdet" --data @"#{Rails.root}/public/external_login/#{email}_login_details.xml" https://www.tataworld.com/TWvalidateuser.asmx`
    `rm -f "#{Rails.root}/public/external_login/#{email}_login_details.xml"`
    @status = str.split("<authencryptuserdetResult>").last.split("</authencryptuserdetResult>").first rescue 'Invalid User'
  end

end
