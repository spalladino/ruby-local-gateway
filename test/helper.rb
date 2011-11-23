require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'test/unit'
require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'ruby-local-gateway'

class Test::Unit::TestCase

  def create_nuntium_channel_for code
    nuntium_client.create_channel({
      :name => 'test_channel', 
      :ticket_code => code, 
      :ticket_message => 'welcome to this test',
      :kind => 'qst_server',
      :protocol => 'sms',
      :direction => 'bidirectional',
      :configuration => { :password => '123456' },
      :enabled => true
    })
  rescue Nuntium::Exception => exception
    p exception
    p exception.properties
  end
 
  def create_nuntium_channel
    nuntium_client.create_channel({
      :name => 'test_channel', 
      :kind => 'qst_server',
      :protocol => 'sms',
      :direction => 'bidirectional',
      :configuration => { :password => '123456' },
      :enabled => true
    })
  rescue Nuntium::Exception => exception
    p exception
    p exception.properties
  end

  def delete_nuntium_channel
    nuntium_client.delete_channel 'test_channel'
  rescue Nuntium::Exception => exception
    p exception
    p exception.properties
  end

  def nuntium_client
    Nuntium.new('http://nuntium.manas.com.ar',
                'localgatewaytest',
                'testapp',
                'testapp')
  end

  def current_etag
    messages_rss_resource.get.headers[:etag] rescue nil
  end

  def messages_received_after etag
    response = messages_rss_resource.get :if_none_match => etag
    (RSS::Parser.parse response, false).items
  end

  def messages_rss_resource
    RestClient::Resource.new('http://nuntium.manas.com.ar/localgatewaytest/testapp/rss',
                                            :user => 'localgatewaytest/testapp',
                                            :password => 'testapp')
  end
end
