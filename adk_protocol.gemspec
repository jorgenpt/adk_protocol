# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "adk_protocol/version"

gem_version = AdkProtocol::VERSION.dup
if ENV.has_key?('BUILD_NUMBER')
  gem_version << ".#{ENV['BUILD_NUMBER']}"
end

Gem::Specification.new do |s|
  s.name        = "adk_protocol"
  s.version     = gem_version
  s.authors     = ["Jørgen P. Tjernø"]
  s.email       = ["jtjerno@mylookout.com"]
  s.homepage    = "https://github.com/jorgenpt/adk_protocol"
  s.summary     = %q{(De)serializer generator for Arduino/Android communication.}
  s.description = %q{This is a Java/C generator for a (de)serializer based on BitStruct, that allows you to very easily define a Arduino/Android communications protocol when using ADK.}

  s.rubyforge_project = "adk_protocol"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'bit-struct'
  s.add_development_dependency 'test-unit', '~> 2.4.5'
end
