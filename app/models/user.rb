class User < ActiveRecord::Base
  
  validates_presence_of :email, :aesop_id
  validates_uniqueness_of :email, :aesop_id
  validates_format_of :email, :with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i  #This regex has not been tested
  
  attr_accessor :response_code, :headers_hash, :response_body
  
  def User.registered?(aesop_id)
    User.find_by_aesop_id(aesop_id) ? true : false
  end
  
  def set_response_details(response)
    @response_code = response.code
    @headers_hash = response.headers_hash
    @response_body = response.body
    #f = File.open( "/Users/jobluz/Desktop/response_body.html", "w" )
    #f.write(response.body)
    parse_and_save_cookies(response.headers_hash["Set-Cookie"])
  end
  
  def parse_and_save_cookies(cookies)
    if cookies.kind_of?(Array)
      attribute_hash = {}
      cookies.each do |c|
        attribute_hash[:guid] = c.gsub(" path=/", "") if c.include? "GUID="
        attribute_hash[:session_id] = c.gsub(" path=/", "") if c.include? "ASPSESSIONID"
        self.update_attributes(attribute_hash)
      end
    elsif cookies.kind_of?(String) && !cookies.nil?
      self.update_attribute(:session_id, cookies)
    end
  end
  
end
