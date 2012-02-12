require 'bit-struct'

require 'ext/bit-struct'
require 'ext/core/string'

require 'adk_protocol/generator'
require 'adk_protocol/message'

module AdkProtocol
  HEADER = "#include <stdint.h>\n"
  def self.generate_c
    code = AdkProtocol::Message.message_types.collect do |type|
      type.generate_c
    end

    HEADER + code.join("\n")
  end
end
