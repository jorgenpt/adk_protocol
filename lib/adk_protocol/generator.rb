module AdkProtocol
  module Generator
    def self.included(base)
      base.extend(ClassMethods)
      base.base_struct = base
    end

    module ClassMethods
      attr_accessor :base_struct
      def command
        # HERP DERP FIX THIS.
        1
      end

      def default_message_name
        name.split('::').last
      end

      def message_name(new_name = nil)
        new_name ? @message_name = new_name : (@message_name or default_message_name)
      end

      def c_name
        message_name.snakecase
      end

      def c_type
        "#{c_name}_t"
      end

      def c_variable
        "#{c_type} super"
      end

      def generate_c_struct
        lines = ["typedef struct _#{c_type} {".with_lineno]
        if superclass.respond_to?(:c_variable)
          lines << "  #{superclass.c_variable};".with_lineno
        end

        lines += own_fields.collect do |f|
          "  #{f.c_variable};".with_lineno
        end

        lines << "} #{c_type};".with_lineno
      end

      def generate_accessors
        accessors = own_fields.collect do |f|
          [f.c_setter(self), f.c_getter(self), f.c_parser(self)]
        end

        accessors.flatten
      end

      def parser_name
        "#{c_name}_parse"
      end

      def generate_parser
        parser = ["uint8_t *#{parser_name}(#{c_type} *msg, uint8_t *buffer, uint32_t size) {".with_lineno]
        parser << "  if (size < #{round_byte_length}) { return 0; }".with_lineno

        if superclass.respond_to?(:parser_name)
          parser << "  uint8_t *running_buffer = #{superclass.parser_name}(&msg->super, buffer, size);".with_lineno
        else
          parser << "  uint8_t *running_buffer = buffer;".with_lineno
          parser << "  if (!running_buffer) { return 0; }"
        end

        # TODO: We only support byte-aligned fields. Extend this to work with
        # bits too.
        parser += own_fields.collect do |f|
          "  running_buffer = #{f.c_parser_name(self)}(msg, running_buffer);".with_lineno
        end

        parser << "  return running_buffer;".with_lineno
        parser << "}"
      end

      def serializer_name
        "#{c_name}_serialize"
      end

      def generate_serializer
        serializer = ["uint8_t *#{serializer_name}(#{c_type} *msg, uint8_t *buffer, uint32_t size) {".with_lineno]
        serializer << "  if (size < #{round_byte_length}) { return 0; }".with_lineno

        if superclass.respond_to?(:serializer_name)
          serializer << "  buffer = #{superclass.serializer_name}(&msg->super, buffer, size);".with_lineno
        else
          serializer << "  if (!buffer) { return 0; }"
        end

        # TODO: We only support byte-aligned fields. Extend this to work with
        # bits too.
        serializer += own_fields.collect do |f|
          "  buffer = #{f.c_serializer_name(self)}(msg, buffer);".with_lineno
        end

        serializer << "  return buffer;".with_lineno
        serializer << "}"
      end

      def generate
        code  = generate_c_struct
        code += generate_accessors
        code += generate_parser
        code += generate_serializer

        code.join("\n") + "\n"
      end
    end
  end
end
