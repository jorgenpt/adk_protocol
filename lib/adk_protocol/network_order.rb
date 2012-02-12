module AdkProtocol
  module NetworkOrder
    HEADER = <<-header.gsub(/^ {6}/, '')
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
end

