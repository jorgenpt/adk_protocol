module AdkProtocol::Generator
  module JavaMessage
    JAVA_TYPES = {
      8  => 'byte',
      16 => 'short',
      32 => 'int',
      64 => 'long',
    }

    def adk_java_name
      message_name
    end

    def generate_java_fields
      own_fields.collect do |f|
        "  public #{f.java_variable};"
      end
    end

    def generate_java_parser
      parser = ["protected boolean parseBuffer(ByteBuffer buffer) {"]
      parser << "  if (buffer.limit() < #{round_byte_length}) { return false; }"

      if superclass.respond_to?(:generate_java_parser)
        parser << "  super.parseBuffer(buffer);"
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

    def generate_java_factory_parser
      class_arg = "Class<? extends #{adk_java_name}>"
      <<-func.gsub(/^ {6}/, '')
        private static HashMap<Integer, #{class_arg}> messages = new HashMap<Integer, #{class_arg}>();

        protected static void registerMessage(int message, #{class_arg} klass) {
          messages.put(new Integer(message), klass);
        }

        public static #{adk_java_name} parse(ByteBuffer buffer) throws InstantiationException, IllegalAccessException {
          buffer.order(ByteOrder.BIG_ENDIAN);
          buffer.mark();
          Message message = new Message();
          message.parseBuffer(buffer);
          buffer.reset();

          Integer type = new Integer(message.command);
          #{class_arg} impl = messages.get(type);

          if (impl == null) {
            return null;
          } else {
            try {
              message = impl.newInstance();
            } catch (Exception e) {
              return null;
            }

            if (message.parseBuffer(buffer)) {
              return message;
            } else {
              return null;
            }
          }
        }
      func
    end

    def generate_java(package)
      code = ["package #{package};"]
      code << "import java.nio.ByteBuffer;"
      if superclass.respond_to?(:adk_java_name)
        code << "public class #{adk_java_name} extends #{superclass.adk_java_name} {"
        code << "  static { #{superclass.adk_java_name}.registerMessage(#{command}, #{adk_java_name}.class); }"
      else
        code << "import java.nio.ByteOrder;"
        code << "import java.util.HashMap;"
        code << "public class #{adk_java_name} {"
        code << generate_java_factory_parser
      end

      code += generate_java_fields
      code += generate_java_parser.collect {|l| "  " + l}
      code += generate_java_serializer.collect {|l| "  " + l}
      code << '}'

      code.join("\n") + "\n"
    end
  end
end
