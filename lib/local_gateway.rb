require 'rubygems'
require 'qst_client'
require 'rest_client'
require 'uri'
require 'json'

class LocalGateway

  attr_accessor :last_received_id
  attr_accessor :ats
  attr_accessor :aos

  attr_accessor :address
  attr_accessor :url
  attr_accessor :user
  attr_accessor :password

  attr_accessor :config_secret_key
  attr_accessor :config_code
  attr_accessor :config_base_url

  def initialize
    ats = []
    aos = []
  end

  def generate_config_code(address, url='http://nuntium.instedd.org/')
    self.address = address
    self.config_base_url = url

    endpoint = URI::join(url, '/tickets.json').to_s
    response = JSON.parse(RestClient.post(endpoint, :address => address))    
    puts response
    self.config_secret_key = response['secret_key']
    self.config_code = response['code']
  end

  def config(url, user, password, address=nil)
    self.url = url
    self.user = user
    self.password = password
    self.address ||= address
    @client = QstClient.new(url, user, password)
    return self
  end

  def send(messages)
    messages = [messages] unless messages.kind_of?(Array)
    messages = messages.map do |m|
      message = m.clone
      message['from'] ||= self.address
      message['from'] = with_protocol(message['from'])
      message['to'] = with_protocol(message['to'])
      message
    end
    @client.put_messages(messages)
  end

  #protected

  def receive
    messages = @client.get_messages :from_id => last_received_id
    puts messages
    return self.last_received_id if messages.empty?
    aos += messages
    self.last_received_id = messages.last['id'] 
  end

  def poll_config_status
    endpoint = URI::join(self.config_base_url, "/tickets/#{self.config_code}.json").to_s
    response = JSON.parse(RestClient.get(endpoint, :params => {:secret_key => config_secret_key}))
    data = response['data']
    
    if response['status'] == 'complete'
      url = URI::join(self.config_base_url, "/#{data['account']}/qst").to_s
      self.config(url, data['channel'], data['password'])
      return data['message']
    else
      return nil
    end
  end

  def with_protocol(address)
    return nil if address.nil? || address.empty?
    return "sms://#{address}" unless address.start_with?('sms://')
  end

end