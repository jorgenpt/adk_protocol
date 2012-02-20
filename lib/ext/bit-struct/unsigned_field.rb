class BitStruct::UnsignedField
  def c_type
    case length
    when 8, 16, 32, 64
      "uint#{length}_t"
    else
      raise AdkProtocol::InvalidLengthException, "#{length} is not supported."
    end
  end

  def adk_java_type
    # We have to use a bigger type to store unsigned values, since Java doesn't
    # have the concept of unsigned types.
    adk_java_real_type(length * 2)
  end

  def java_parser(buffer)
    snippet = "  #{name} = (#{adk_java_type})(#{buffer}.get"
    snippet += adk_java_real_type.capitalize unless adk_java_real_type == 'byte'
    snippet += "() & 0x#{((1 << length) - 1).to_s(16)});"

    [snippet]
  end

  def java_serializer(buffer)
    snippet = "  #{buffer}.put"
    snippet += adk_java_real_type.capitalize unless adk_java_real_type == 'byte'
    snippet += "((#{adk_java_real_type})#{name});"

    [snippet]
  end

  include AdkProtocol::NetworkOrder
end
