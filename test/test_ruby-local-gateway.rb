require 'helper'
require 'nuntium_api'
require 'rss/1.0'
require 'rss/2.0'
# require 'vcr'


class TestRubyLocalGateway < Test::Unit::TestCase
  should "have default address and protocol" do
    lgw = LocalGateway.new 'http://nuntium.manas.com.ar/localgatewaytest/qst',
              'test_channel',
              'test_channel'
    assert_equal lgw.url, 'http://nuntium.manas.com.ar/localgatewaytest/qst'
    assert_equal lgw.user, 'test_channel'
    assert_equal lgw.password, 'test_channel'
    assert_equal lgw.address, '9990000'
    assert_equal lgw.protocol, 'sms'

    lgw = LocalGateway.new 'http://nuntium.manas.com.ar/localgatewaytest/qst',
              'test_channel',
              'test_channel',
              '12345',
              'foo'
    assert_equal lgw.address, '12345'
    assert_equal lgw.protocol, 'foo'
  end

  should "configure with tickets" do
    begin
      welcome_message, lgw = LocalGateway.with_automatic_configuration_for 'http://nuntium.manas.com.ar/' do | ticket_number |
        create_nuntium_channel_for ticket_number
      end
      assert_equal 'welcome to this test', welcome_message
      assert_equal 'http://nuntium.manas.com.ar/localgatewaytest/qst', lgw.url
      assert_equal 'test_channel', lgw.user
      assert_equal '123456', lgw.password
      assert_equal '9990000', lgw.address
      assert_equal 'sms', lgw.protocol
    ensure
      delete_nuntium_channel
    end
  end

  should "send message" do
    begin
      create_nuntium_channel
      etag = current_etag
      #-------------------------------------------------
      lgw = LocalGateway.new 'http://nuntium.manas.com.ar/localgatewaytest/qst',
              'test_channel',
              '123456'

      lgw.send_at 'ble', to: '122202'
      #-------------------------------------------------
      received_messages = messages_received_after etag

      assert_equal 1, received_messages.size
      message = received_messages.first
      assert_equal 'ble', message.title
      assert_equal 'sms://9990000', message.author
    ensure
      delete_nuntium_channel
    end
  end

  should "receive message" do
    begin
      create_nuntium_channel

      lgw = LocalGateway.new 'http://nuntium.manas.com.ar/localgatewaytest/qst',
              'test_channel',
              '123456'


      api = Nuntium.new "http://nuntium.manas.com.ar", "localgatewaytest", "testapp", "testapp"

      message = {
        :from => "sms://1234",
        :to => "sms://5678",
        :body => "Hello Nuntium!",
      }

      api.send_ao message

      messages = lgw.receive_aos
      assert_equal 1,  messages.size
      message = messages.first
      assert_equal "Hello Nuntium!", message['text']
      assert_equal "sms://1234", message['from']
      assert_equal "sms://5678", message['to']
      assert_equal 0, lgw.receive_aos.size, 'The message must be received only once'
    ensure
      delete_nuntium_channel
    end
  end
end
