module AdkProtocol
  module Generator
    require 'adk_protocol/generator/c'

    def self.included(base)
      base.extend(ClassMethods)
      base.base_struct = base
    end

    module ClassMethods
      attr_accessor :base_struct
      def command
        # HERP DERP FIX THIS.
        1
      end

      def default_message_name
        name.split('::').last
      end

      def message_name(new_name = nil)
        new_name ? @message_name = new_name : (@message_name or default_message_name)
      end

      include C
    end
  end
end
