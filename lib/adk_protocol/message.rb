module AdkProtocol
  class Message < BitStruct
    include Generator

    unsigned :protocol_signature, 32, "A signature for the protocol version"
    unsigned :command, 32, "The command"
  end
end
