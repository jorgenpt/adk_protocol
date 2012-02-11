class BitStruct::UnsignedField
  def c_type
    case length
    when 8, 16, 32, 64
      "uint#{length}_t"
    else
      raise AdkProtocol::InvalidLengthException, "#{length} is not supported."
    end
  end

  def c_parser_function
    if length == 8
      ""
    else
      "ntoh#{c_shorthand}"
    end
  end

  def c_serializer_function
    if length == 8
      ""
    else
      "hton#{c_shorthand}"
    end
  end
end
