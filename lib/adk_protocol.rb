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

    header  = [HEADER, "enum _message_types {"]
    header += types.collect do |type|
      "  #{type.constant_name} = #{type.command},"
    end
    header << "};"
    header << "typedef enum _message_types message_types;"

    implementation = [AdkProtocol::NetworkOrder::HEADER]

    types.collect do |type|
      type.generate_c.each do |snippet|
        if snippet.respond_to?(:prototype)
          header << snippet.prototype
          implementation << snippet.to_s
        else
          header << snippet.join("\n")
        end
      end
    end

    yield header.join("\n"), implementation.join("\n")
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
      yield type.adk_java_name, type.generate_java(package)
    end
  end
end
