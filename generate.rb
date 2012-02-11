#!/usr/bin/env ruby
$LOAD_PATH << 'lib'
$LOAD_PATH << '.'

require 'adk_protocol'
require 'rfid_message'

puts "#include <stdint.h>"
puts AdkProtocol::Message.generate
puts RfidMessage.generate
