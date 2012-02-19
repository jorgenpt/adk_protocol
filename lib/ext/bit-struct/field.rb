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

  def c_parser(msg, buffer)
    ["  #{msg}->#{name} = #{c_parser_function}(*((#{c_type} *)#{buffer}));",
     "  #{buffer} += #{round_byte_length};"]
  end

  def c_serializer(msg, buffer)
    ["  (*((#{c_type} *)#{buffer})) = #{c_serializer_function}(#{msg}->#{name});",
     "  #{buffer} += #{round_byte_length};"]
  end

  def java_variable
    "#{java_type} #{name}"
  end

  def java_type
    java_real_type
  end

  def java_real_type(length_override=nil)
    type = AdkProtocol::Generator::JavaMessage::JAVA_TYPES[length_override ? length_override : length]
    if not type
      raise AdkProtocol::InvalidLengthException, "#{length} is not supported."
    else
      type
    end
  end
end
