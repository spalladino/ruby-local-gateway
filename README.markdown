Local Gateway
=============

A Local Gateway -developed by InSTEDD- implemented in Ruby for testing purposes.

Install
-------

gem install local\_gateway

Gemfile
-------

gem 'local\_gateway'

Usage
-----
    # Ask for a ticket.
    # Returns the welcome message and the newly created local gateway.
    msg, lgw = LocalGateway.with_automatic_configuration_for do |ticket_number|
      # Create nuntium channel with ticket number
    end

    lgw.send_at 'Hello!', to: '1234'

    aos = lgw.receive_aos
