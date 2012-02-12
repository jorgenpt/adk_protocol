class BitStruct::UnsignedField
  def c_type
    case length
    when 8, 16, 32, 64
      "uint#{length}_t"
    else
      raise AdkProtocol::InvalidLengthException, "#{length} is not supported."
    end
  end

  include AdkProtocol::NetworkOrder
end
