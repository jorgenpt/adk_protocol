require 'digest/sha1'

module AdkProtocol
  module Generator
    require 'adk_protocol/generator/c_message'
    require 'adk_protocol/generator/java_message'

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def command
        Digest::SHA1.digest(name)[-4..-1].unpack('N').first
      end

      def default_message_name
        name.split('::').last
      end

      def message_name(new_name = nil)
        new_name ? @message_name = new_name : (@message_name or default_message_name)
      end

      def constant_name
        message_name.upcase
      end

      include CMessage
      include JavaMessage
    end
  end
end
