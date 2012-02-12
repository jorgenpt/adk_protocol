require 'bit-struct'

require 'ext/bit-struct'
require 'ext/core/string'

require 'adk_protocol/generator'
require 'adk_protocol/message'

module AdkProtocol
  HEADER = <<-header.gsub(/^ {4}/, '')
    #include <stdint.h>
    #if HAVE_ARPA_INET_H
    # include <arpa/inet.h>
    #else
    # if BIG_ENDIAN // We default to assuming little-endian.
    #  define htons(n) (n)
    #  define htonl(n) (n)
    #  define ntohs(n) (uint16_t)((((uint16_t) (n)) << 8) | (((uint16_t) (n)) >> 8))
    #  define ntohl(n) (((uint32_t)htons(n) << 16) | htons((uint32_t)(n) >> 16))
    # else
    #  define htons(n) (uint16_t)((((uint16_t) (n)) << 8) | (((uint16_t) (n)) >> 8))
    #  define htonl(n) (((uint32_t)htons(n) << 16) | htons((uint32_t)(n) >> 16))
    #  define ntohs(n) (n)
    #  define ntohl(n) (n)
    # endif
    #endif
  header

  def self.generate_c
    code = AdkProtocol::Message.message_types.collect do |type|
      type.generate_c
    end

    HEADER.to_s + code.join("\n")
  end
end
