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
      lines = ["struct _#{c_name}_t {".with_lineno]
      if superclass.respond_to?(:c_variable)
        lines << "  #{superclass.c_variable};".with_lineno
      end

      lines += own_fields.collect do |f|
        "  #{f.c_variable};".with_lineno
      end

      lines << "};".with_lineno
      lines << "typedef #{c_type} #{c_name}_t;"
    end

    def c_parser_name
      "#{c_name}_parse"
    end

    def generate_c_parser
      parser = ["uint8_t *#{c_parser_name}(#{c_type} *msg, uint8_t *buffer, uint32_t size) {".with_lineno]
      parser << "  if (size < #{round_byte_length}) { return 0; }".with_lineno

      if superclass.respond_to?(:c_parser_name)
        parser << "  buffer = #{superclass.c_parser_name}(&msg->super, buffer, size);".with_lineno
      else
        parser << "  if (!buffer) { return 0; }".with_lineno
      end

      # TODO: We only support byte-aligned fields. Extend this to work with
      # bits too.
      parser += own_fields.collect do |f|
        f.c_parser('msg', 'buffer').join("\n")
      end

      parser << "  return buffer;".with_lineno
      parser << "}"
    end

    def c_serializer_name
      "#{c_name}_serialize"
    end

    def generate_c_serializer
      serializer = ["uint8_t *#{c_serializer_name}(#{c_type} *msg, uint8_t *buffer, uint32_t size) {".with_lineno]
      serializer << "  if (size < #{round_byte_length}) { return 0; }".with_lineno

      if superclass.respond_to?(:c_serializer_name)
        serializer << "  buffer = #{superclass.c_serializer_name}(&msg->super, buffer, size);".with_lineno
      else
        serializer << "  if (!buffer) { return 0; }".with_lineno
      end

      # TODO: We only support byte-aligned fields. Extend this to work with
      # bits too.
      serializer += own_fields.collect do |f|
        f.c_serializer('msg', 'buffer').join("\n")
      end

      serializer << "  return buffer;".with_lineno
      serializer << "}"
    end

    def generate_c
      code  = generate_c_struct
      code += generate_c_parser
      code += generate_c_serializer

      code.join("\n") + "\n"
    end
  end
end
