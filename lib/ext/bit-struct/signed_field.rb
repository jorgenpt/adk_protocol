class BitStruct::SignedField
  def c_type
    case length
    when 8, 16, 32, 64
      "int#{length}_t"
    else
      raise AdkProtocol::InvalidLengthException, "#{length} is not supported."
    end
  end

  def java_parser(buffer)
    snippet = "  #{name} = #{buffer}.get"
    snippet += java_type.capitalize unless java_type == 'byte'
    snippet += "();"

    [snippet]
  end

  def java_serializer(buffer)
    snippet = "  #{buffer}.put"
    snippet += java_type.capitalize unless java_type == 'byte'
    snippet += "(#{name});"

    [snippet]
  end

  include AdkProtocol::NetworkOrder
end
