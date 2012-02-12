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
    ["  #{msg}->#{name} = #{c_parser_function}(*((#{c_type} *)#{buffer}));".with_lineno,
     "  #{buffer} += #{round_byte_length};".with_lineno]
  end

  def c_serializer(msg, buffer)
    ["  (*((#{c_type} *)#{buffer})) = #{c_serializer_function}(#{msg}->#{name});".with_lineno,
     "  #{buffer} += #{round_byte_length};".with_lineno]
  end
end
