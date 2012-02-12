class BitStruct::UnsignedField
  def c_type
    case length
    when 8, 16, 32, 64
      "uint#{length}_t"
    else
      raise AdkProtocol::InvalidLengthException, "#{length} is not supported."
    end
  end

  def java_type
    # We have to use a bigger type to store unsigned values, since Java doesn't
    # have the concept of unsigned types.
    java_real_type(length * 2)
  end

  def java_parser(buffer)
    snippet = "  #{name} = (#{java_type})(#{buffer}.get"
    snippet += java_real_type.capitalize unless java_real_type == 'byte'
    snippet += "() & 0x#{((1 << length) - 1).to_s(16)});"

    [snippet]
  end

  def java_serializer(buffer)
    snippet = "  #{buffer}.put"
    snippet += java_real_type.capitalize unless java_real_type == 'byte'
    snippet += "((#{java_real_type})#{name});"

    [snippet]
  end

  include AdkProtocol::NetworkOrder
end
