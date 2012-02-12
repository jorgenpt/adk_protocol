#!/usr/bin/env ruby
$LOAD_PATH << 'lib'

require 'adk_protocol'
require './rfid_message'

puts AdkProtocol.generate_c
