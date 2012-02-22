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

      parser << "if (size < #{round_byte_length}) { return 0; }"

      if superclass.respond_to?(:c_parser_name)
        parser << "buffer = #{superclass.c_parser_name}(&msg->super, buffer, size);"
      else
        parser << "if (!buffer) { return 0; }"
      end

      # TODO: We only support byte-aligned fields. Extend this to work with
      # bits too.
      own_fields.each do |f|
        f.c_parser('msg', 'buffer').each do |line|
          parser << line
        end
      end

      parser << "return buffer;"
    end

    def generate_c_factory_parser(allocator)
      code = []
      parser = CFunction.new("uint8_t*", 'adk_parse', 'uint8_t* buffer', 'uint32_t size', "#{c_type}** msg")

      if allocator == :static
        code << 'union {'
        message_types.each do |type|
          code << "  #{type.c_type} #{type.c_name};"
        end
        code << '} _static_storage;'
      end

      parser << "#{c_type} #{c_name};"
      parser << "if (!#{c_parser_name}(&#{c_name}, buffer, size))"
      parser << "  return 0;"
      parser << "switch (#{c_name}.command) {"
      message_types.each do |type|
        parser << "  case #{type.constant_name}: {"
        parser << "    #{type.c_type} *parsed_msg ="
        if allocator == :static
          parser << "      &_static_storage.#{type.c_name};"
        else
          parser << "      calloc(sizeof(#{type.c_type}));"
        end
        parser << "    buffer = #{type.c_parser_name}(parsed_msg, buffer, size);"
        parser << "    if (buffer) *msg = (#{c_type}*)parsed_msg;"
        parser << "    break;"
        parser << "  }"
      end
      parser << "  default: return 0;"
      parser << "}"

      parser << "return buffer;"

      [code, parser]
    end

    def c_serializer_name
      "#{c_name}_serialize"
    end

    def generate_c_serializer
      serializer = CFunction.new('uint8_t*', c_serializer_name, "#{c_type}* msg", 'uint8_t* buffer', 'uint32_t size')
      serializer << "if (size < #{round_byte_length}) { return 0; }"
      serializer << "if (#{c_get_command_name}(msg) == 0)"
      serializer << "  #{c_set_command_name}(msg, #{constant_name});"


      if superclass.respond_to?(:c_serializer_name)
        serializer << "buffer = #{superclass.c_serializer_name}(&msg->super, buffer, size);"
      else
        serializer << "if (!buffer) { return 0; }"
      end

      # TODO: We only support byte-aligned fields. Extend this to work with
      # bits too.
      own_fields.collect do |f|
        f.c_serializer('msg', 'buffer').each do |line|
          serializer << line
        end
      end

      serializer << "return buffer;"
    end

    def c_set_command_name
      "#{c_name}_set_command"
    end

    def c_get_command_name
      "#{c_name}_get_command"
    end

    def generate_c_command_accessors
      setter = CFunction.new('void', c_set_command_name, "#{c_type}* msg", "int32_t command")
      getter = CFunction.new('int32_t', c_get_command_name, "#{c_type}* msg")

      if superclass.respond_to?(:c_set_command_name)
        setter << "#{superclass.c_set_command_name}(&msg->super, command);"
        getter << "return #{superclass.c_get_command_name}(&msg->super);"
      else
        setter << "msg->command = command;"
        getter << "return msg->command;"
      end

      [setter, getter]
    end

    def generate_c
      code  = [generate_c_struct]
      code += generate_c_command_accessors
      code << generate_c_parser
      code << generate_c_serializer
    end
  end
end
