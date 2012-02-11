class BitStruct::Field
  def round_byte_length
    (length/8.0).ceil.to_i
  end

  def c_shorthand
    case length
    when 16; "s"
    when 32; "l"
    when 64; "ll"
    else
      raise AdkProtocol::InvalidLengthException, "#{length} is not supported."
    end
  end

  def c_variable
    "#{c_type} #{name}"
  end

  def c_parser_name(struct)
      "#{struct.c_name}_parse_#{name}"
  end

  def c_parser(struct)
    <<-func.gsub(/^ {6}/, '').with_lineno
      uint8_t *#{c_parser_name(struct)}(#{struct.c_type} *msg, uint8_t *buffer) {
        msg->#{name} = #{c_parser_function}(*((#{c_type} *)buffer));
        return buffer + #{round_byte_length};
      }
    func
  end

  def c_serializer_name(struct)
      "#{struct.c_name}_parse_#{name}"
  end

  def c_serializer(struct)
    <<-func.gsub(/^ {6}/, '').with_lineno
      uint8_t *#{c_serializer_name(struct)}(#{struct.c_type} *msg, uint8_t *buffer) {
        *((#{c_type} *)buffer) = #{c_serializer_function}(msg->#{name});
        return buffer + #{round_byte_length};
      }
    func
  end

  def c_setter_name(struct)
      "#{struct.c_name}_set_#{name}"
  end

  def c_setter(struct)
    <<-func.gsub(/^ {6}/, '').with_lineno
      void #{c_setter_name(struct)}(#{struct.c_type} *msg, #{c_variable}) {
        ((#{struct.c_name}_t *)msg)->#{name} = #{name};
      }
    func
  end

  def c_getter_name(struct)
    "#{struct.c_name}_get_#{name}"
  end

  def c_getter(struct)
    <<-func.gsub(/^ {6}/, '').with_lineno
      #{c_type} #{c_getter_name(struct)}(#{struct.c_type} *msg) {
        return ((#{struct.c_name}_t *)msg)->#{name};
      }
    func
  end
end
