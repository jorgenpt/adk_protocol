require 'adk_protocol/generator/c_function'

module AdkProtocol::Generator
  module CMessage
    def c_name
      message_name.snakecase
    end

    def c_type
      "struct _#{c_name}_t"
    end

    def c_variable
      "#{c_type} super"
    end

    def generate_c_struct
      lines = ["struct _#{c_name}_t {"]
      if superclass.respond_to?(:c_variable)
        lines << "  #{superclass.c_variable};"
      end

      lines += own_fields.collect do |f|
        "  #{f.c_variable};"
      end

      lines << "};"
      lines << "typedef #{c_type} #{c_name}_t;"
    end

    def c_parser_name
      "#{c_name}_parse"
    end

    def generate_c_parser
      parser = CFunction.new('uint8_t*', c_parser_name, "#{c_type}* msg", 'uint8_t* buffer', 'uint32_t size')

      parser << "  if (size < #{round_byte_length}) { return 0; }"

      if superclass.respond_to?(:c_parser_name)
        parser << "  buffer = #{superclass.c_parser_name}(&msg->super, buffer, size);"
      else
        parser << "  if (!buffer) { return 0; }"
      end

      # TODO: We only support byte-aligned fields. Extend this to work with
      # bits too.
      own_fields.each do |f|
        parser << f.c_parser('msg', 'buffer').join("\n")
      end

      parser << "  return buffer;"
    end

    def c_serializer_name
      "#{c_name}_serialize"
    end

    def generate_c_serializer
      serializer = CFunction.new('uint8_t*', c_serializer_name, "#{c_type}* msg", 'uint8_t* buffer', 'uint32_t size')
      serializer << "  if (size < #{round_byte_length}) { return 0; }"

      if superclass.respond_to?(:c_serializer_name)
        serializer << "  buffer = #{superclass.c_serializer_name}(&msg->super, buffer, size);"
      else
        serializer << "  if (!buffer) { return 0; }"
      end

      # TODO: We only support byte-aligned fields. Extend this to work with
      # bits too.
      own_fields.collect do |f|
        serializer << f.c_serializer('msg', 'buffer').join("\n")
      end

      serializer << "  return buffer;"
    end

    def generate_c
      code  = [generate_c_struct]
      code << generate_c_parser
      code << generate_c_serializer
    end
  end
end
