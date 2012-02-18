module AdkProtocol::Generator
  module JavaMessage
    JAVA_TYPES = {
      8  => 'byte',
      16 => 'short',
      32 => 'int',
      64 => 'long',
    }

    def java_name
      message_name
    end

    def generate_java_fields
      own_fields.collect do |f|
        "  public #{f.java_variable};"
      end
    end

    def generate_java_parser
      parser = ["public boolean parse(ByteBuffer buffer) {"]
      parser << "  if (buffer.limit() < #{round_byte_length}) { return false; }"

      if superclass.respond_to?(:generate_java_parser)
        parser << "  super.parse(buffer);"
      end

      # TODO: We only support byte-aligned fields. Extend this to work with
      # bits too.
      parser += own_fields.collect do |f|
        f.java_parser('buffer').join("\n")
      end

      parser << "  return true;"
      parser << "}"
    end

    def generate_java_serializer
      serializer = ["public boolean serialize(ByteBuffer buffer) {"]
      serializer << "  if (buffer.limit() - buffer.position() < #{round_byte_length}) { return false; }"

      if superclass.respond_to?(:generate_java_serializer)
        serializer << "  super.serialize(buffer);"
      end

      # TODO: We only support byte-aligned fields. Extend this to work with
      # bits too.
      serializer += own_fields.collect do |f|
        f.java_serializer('buffer').join("\n")
      end

      serializer << "  return true;"
      serializer << "}"
    end

    def generate_java(package)
      code = ["package #{package};"]
      code << "import java.nio.ByteBuffer;"
      if superclass.respond_to?(:java_name)
        code << "public class #{java_name} extends #{superclass.java_name} {"
      else
        code << "public class #{java_name} {"
      end

      code += generate_java_fields
      code += generate_java_parser
      code += generate_java_serializer
      code << '}'

      code.join("\n") + "\n"
    end
  end
end
