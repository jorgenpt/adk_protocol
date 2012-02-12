require 'bit-struct'

require 'adk_protocol/network_order'

require 'ext/bit-struct'
require 'ext/core/string'

require 'adk_protocol/generator'
require 'adk_protocol/message'

module AdkProtocol
  HEADER = "#include <stdint.h>"
  def self.generate_c
    code = AdkProtocol::Message.message_types.collect do |type|
      type.generate_c
    end

    "#{HEADER}\n#{AdkProtocol::NetworkOrder::HEADER}\n#{code.join("\n")}"
  end

  def self.generate_java
    code = AdkProtocol::Message.message_types.collect do |type|
      type.generate_java
    end

    code.join("\n")
  end
end
