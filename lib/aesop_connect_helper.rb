require 'typhoeus'

module AesopConnectHelper
  
  def login_aesop(user, aesop_pin)
    request = Typhoeus::Request.new(
      "https://www.aesoponline.com/login.asp?x=x&&pswd=",
      :method => :post,
      :verbose => true,
      :user_agent => user.user_agent,
      :params => {:location => "", 
        :qstring => "", 
        :absr_ID => "", 
        :foil => "", 
        :id => "#{user.aesop_id}", 
        :pin => "#{aesop_pin}", 
        "submit.x".to_sym => "32", 
        "submit.y".to_sym => "15"
      }
    )
    
    response = run_request(request)
    user.set_response_details(response)
    status_ok(user.response_code)
  end
  
  def aesop_job_list(user)
    request = Typhoeus::Request.new(
      'https://www.aesoponline.com/subweb/sub_searchforjobs.asp?x=x&sub_id=All&SHOWALLJOBS=1', 
      :method => :get,
      :verbose => true,
      :user_agent => user.user_agent,
      :headers => {"Referer" => 'https://www.aesoponline.com/subweb/sub_default.asp?x=x&setcookie=true&sub_id=All',
        "Cookie" => "#{user.guid} #{user.session_id}"
      }
    )
    
    response = run_request(request)
    user.set_response_details(response)
    status_ok(user.response_code)
  end
  
  def aesop_accept_job(user, hcc, absr_id)
    request = Typhoeus::Request.new(
      "https://www.aesoponline.com/subweb/sub_accept_job.asp?GUID=#{user.guid}&hcc=#{hcc}&absr_id=#{absr_id}&Accept=Accept+Job", 
      :method => :get,
      :verbose => true,
      :user_agent => user.user_agent,
      :headers => {"Referer" => 'https://www.aesoponline.com/subweb/sub_default.asp?x=x&setcookie=true&sub_id=All',
        "Cookie" => "#{user.guid} #{user.session_id}"
      }
    )
    
    response = run_request(request)
    user.set_response_details(response)
    status_ok(user.response_code)
  end
  
  def aesop_details_page(user, absr_id)
    request = Typhoeus::Request.new(
      "https://www.aesoponline.com/subweb/sub_accept_job.asp?absr_id=#{absr_id}", 
      :method => :get,
      :verbose => true,
      :user_agent => user.user_agent,
      :headers => {"Referer" => 'https://www.aesoponline.com/subweb/sub_searchforjobs.asp?x=x&sub_id=&SHOWALLJOBS=1&SORTBY=1',
        "Cookie" => "#{user.guid} #{user.session_id}"
      }
    )
    
    response = run_request(request)
    user.set_response_details(response)
    status_ok(user.response_code)
  end
  
  def aesop_reject_job(user, hcc, absr_id)
    request = Typhoeus::Request.new(
      "https://www.aesoponline.com/subweb/sub_accept_job.asp?#{user.guid}&hcc=#{hcc}&absr_id=#{absr_id}&Reject=Reject+Job".gsub(";",""), 
      :method => :get, 
      :verbose => true, 
      :headers => {"Referer" => "https://www.aesoponline.com/subweb/sub_accept_job.asp?absr_id=#{absr_id}", 
        "Cookie" => "#{user.guid} #{user.session_id}"
      }
    )
    
    response = run_request(request)
    user.set_response_details(response)
    status_ok(user.response_code) || user.response_code == 302
  end
  
  def aesop_logout(user)
    request = Typhoeus::Request.new(
      "https://www.aesoponline.com/login.asp?x=x&login=exp",
      :method => :get,
      :verbose => true,
      :user_agent => user.user_agent,
      :headers => {"Referer" => 'https://www.aesoponline.com/subweb/sub_searchforjobs.asp?SHOWALLJOBS=1&?x=x',
        "Cookie" => "#{user.guid} #{user.session_id}"
      }
    )
    
    response = run_request(request)
    user.set_response_details(response)
    status_ok(user.response_code)
  end
  
  def run_request(request)
    hydra = Typhoeus::Hydra.new
    hydra.queue request
    hydra.run
    request.response
  end
  
  def status_ok(status_code)
    (status_code == 200) || (status_code == 304)
  end
end