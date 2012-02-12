module AdkProtocol
  class Message < BitStruct
    include Generator

    class << self
      def message_types
        @message_types or (@message_types = [self])
      end

      def inherited(subclass)
        if superclass.respond_to?(:inherited)
          superclass.inherited(subclass)
        end

        message_types << subclass
      end
    end

    unsigned :protocol_signature, 32, "A signature for the protocol version"
    unsigned :command, 32, "The command"
  end
end
