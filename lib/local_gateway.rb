require 'rubygems'
require 'qst_client'
require 'rest_client'
require 'uri'
require 'json'

# A local gateway that sends ATs and receives AOs.
#
# Usage:
#
#   # Ask for a ticket.
#   # Returns the welcome message and the newly created local gateway.
#   msg, lgw = LocalGateway.with_automatic_configuration_for do |ticket_number|
#     # Create nuntium channel with ticket number
#   end
#
#   lgw.send_at 'Hello!', to: '1234'
#
#   aos = lgw.receive_aos
class LocalGateway
  attr_reader :address
  attr_reader :url
  attr_reader :user
  attr_reader :password
  attr_reader :protocol

  # Creates a new local gateway for an existing qst server channel.
  def initialize(url, user, password, address = self.class.default_address, protocol = self.class.default_protocol)
    @address = address
    @url = url
    @user = user
    @password = password
    @protocol = protocol
    @client = QstClient.new(url, user, password)
    return self
  end

  # Creates a new local gateway that asks for a ticket number, yields it to the block,
  # then polls the ticket status. You must normally create a nuntium channel inside the given block.
  def self.with_automatic_configuration_for(url='http://nuntium.instedd.org/', address = default_address, protocol = default_protocol)
    response = request_configuration_code url, address
    yield response['code']
    data = poll_configuration_status response['code'], response['secret_key'], url
    url = URI::join(url, "/#{data['account']}/qst").to_s
    [data['message'], self.new(url, data['channel'], data['password'])]
  end

  # Sends an AT message to nuntium.
  #
  #   lgw.send_at 'Hello!', to: '1234'
  def send_at(text, options)
    message = {'text' => text, 'to' => options[:to]}
    send_ats message
  end

  # Recieves AOs from nuntium.
  def receive_aos
    messages = if @last_received_id.nil?
                 @client.get_messages
               else
                 @client.get_messages :from_id => @last_received_id
               end
    @last_received_id = messages.last['id'] unless messages.empty?
    messages
  end

  # Sends many AT messages.
  #
  #   send_ats [{from: '123', to: '4656', text: 'Hello'}, ...]
  def send_ats(messages)
    messages = [messages] unless messages.kind_of?(Array)
    messages = messages.map do |m|
      message = m.clone
      message['from'] ||= self.address
      message['from'] = with_protocol(message['from'] || message[:from])
      message['to'] = with_protocol(message['to'] || message[:to])
      message
    end
    @client.put_messages(messages)
  end


  private

  def with_protocol(address)
    return nil if address.nil? || address.empty?
    return "#{protocol}://#{address}" unless address.start_with?("#{protocol}://")
  end

  def self.request_configuration_code(url, address)
    endpoint = URI::join(url, '/tickets.json').to_s
    JSON.parse(RestClient.post(endpoint, :address => address))
  end

  def self.poll_configuration_status(code, secret_key, url)
    endpoint = URI::join(url, "/tickets/#{code}.json").to_s
    10.times do
      response = JSON.parse(RestClient.get(endpoint, :params => {:secret_key => secret_key}))
      return response['data'] if response['status'] == 'complete'
    end
    raise "Channel for ticket #{code} does not exist"
  end

  def self.default_protocol
    'sms'
  end

  def self.default_address
    '9990000'
  end
end
