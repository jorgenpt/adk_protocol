require 'bit-struct'

require 'adk_protocol/network_order'

require 'ext/bit-struct'
require 'ext/core/string'

require 'adk_protocol/generator'
require 'adk_protocol/message'

module AdkProtocol
  HEADER = "#include <stdint.h>"
  def self.generate_c
    types = AdkProtocol::Message.message_types

    code  = ["enum _message_types {"]
    code += types.collect do |type|
      "  #{type.constant_name} = #{type.command},"
    end
    code << "};"
    code << "typedef enum _message_types message_types;"

    code += types.collect do |type|
      type.generate_c
    end

    #  TODO: This needs to yield the function declarations as its first
    #  argument.
    yield '', "#{HEADER}\n#{AdkProtocol::NetworkOrder::HEADER}\n#{code.join("\n")}"
  end

  def self.generate_java(package)
    types = AdkProtocol::Message.message_types

    code  = ["package #{package};"]
    code << "public class MessageTypes {"
    types.each do |type|
      code << "  public static final int #{type.constant_name} = #{type.command};"
    end
    code << "};"

    yield 'MessageTypes', code.join("\n")

    types.each do |type|
      yield type.java_name, type.generate_java(package)
    end
  end
end
