#!/usr/bin/env ruby
$LOAD_PATH << 'lib'

require 'adk_protocol'
require './test/test_message'

puts AdkProtocol.generate_c
