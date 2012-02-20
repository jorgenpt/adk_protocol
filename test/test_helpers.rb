require 'rubygems'
require 'bundler/setup'

root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
$LOAD_PATH << "#{root}/lib" << "#{root}/test"

require 'test-unit'
require 'adk_protocol'

require 'test_message'

require 'c_helpers'
require 'java_helpers'
