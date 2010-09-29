require 'common_pool'
require 'pooled_curb_datasource'

# wrapper on top of curb to ensure we reuse the Curl objects, and thus make sure we  
# benefit from keep-alive
#
# Usage:
#
#   PooledCurb.get(url)
#
#   PooledCurb.post(url, {:hash => 'of', :several => 'parameters})
#   PooledCurb.post(url, request_body)
#
#   PooledCurb.put(url, request_body)

class PooledCurb

  #NOTE: curb documentation lives in http://rubydoc.info/github/taf2/curb/

  HTTP_CLIENT_POOL = CommonPool::ObjectPool.new(PooledCurbDataSource.new) {|config| config.max_active = 200 }
  
  def self.with_client
    curl = HTTP_CLIENT_POOL.borrow_object
    begin
      yield curl
    rescue Curl::Err::MultiBadEasyHandle
      # obtener una nueva
      curl = HTTP_CLIENT_POOL.borrow_object
      retry
    ensure
      HTTP_CLIENT_POOL.return_object(curl)
    end
  end

  # get the URL, returns body_str, responde_code
  def self.get(url, timeout = 20)
    with_client do |curl|
      curl.timeout = timeout
      curl.url = url
      curl.http("GET")
      return curl.body_str, curl.response_code
    end
  end

  # get the URL, retrying upto max_retries times if an error is found. 
  #
  # When a code block is given, it will be used as a validation function
  # for the response, otherwise and standard validation that tests that response code is 200
  # and the body is not nil will be used
  #
  # for example
  #
  #  PooledCurb.get_with_retry(url) {|body, code| body !~ /ERROR/}

  def self.get_with_retry(url, timeout = 20, max_retries = 5)
    
    body = nil
    
    max_retries.times do |ix_try|
      
      # If the target server is down for a very short time, a very short sleep after the third failure
      # will help us recover the error
      Kernel.sleep(0.2) if ix_try > 3

      begin
        body, response_code = get(url, timeout)

        if block_given?
          next unless yield body, response_code
        else
          next unless response_code == 200 && body.any?
        end
        
        return body        
      rescue Curl::Err::CurlError
        # will retry
      end
    end
    
    body
  end

  # post to the URL, returns body_str, responde_code
  #
  # can accept a hash of parameters or a string containing the request body 
  
  def self.post(url, params_or_body = {}, timeout = 20)
    with_client do |curl|
      curl.timeout = timeout
      curl.url = url
      if params_or_body.kind_of?(String)
        curl.http_post url, params_or_body
      else
        params = params_or_body
        fields = params.keys.map{|param_name| Curl::PostField.content(param_name, params[param_name]) }
        curl.http_post url, *fields
      end
      return curl.body_str, curl.response_code
    end
  end
  
  # put to the URL, returns body_str, responde_code
  def self.put(url, request_body, timeout = 20)
    with_client do |curl|
      curl.timeout = timeout
      curl.url = url
      curl.http_put request_body
      return curl.body_str, curl.response_code
    end
  end
  
end