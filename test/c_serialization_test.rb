require File.absolute_path(File.dirname(__FILE__) + '/test_helpers')

require 'test_message'

class CSerializationTest < Test::Unit::TestCase
  include CBuilder

  def setup
    @setup_source  = "#include <stdint.h>\n#include <stdio.h>\n"
    @setup_source += AdkProtocol::Message.generate
    @setup_source += TestMessage.generate
  end

  def test_build
    noop_binary = build(@setup_source, 'int main() { return 0; }')
    assert_true(File.exist?(noop_binary))
    assert_true(system(noop_binary))
  end

  def test_roundtrip
    roundtrip_source = <<-source.gsub(/^ {6}/, '').with_lineno
      int main() {
        test_message_t msg1 = {0}, msg2;
        char buffer[sizeof(test_message_t)], *buffer_left;

        test_message_set_u8(&msg1, 255);
        test_message_set_u16(&msg1, 65535);
        test_message_set_u32(&msg1, 4294967295);

        buffer_left = test_message_serialize(&msg1, buffer, sizeof(buffer));
        printf("0 != %p: Serialize should succeed\\n", buffer_left);
        if (!buffer_left) {
          return 0;
        }

        buffer_left = test_message_parse(&msg2, buffer, sizeof(buffer));
        printf("0 != %p: Parse should succeed\\n", buffer_left);
        if (!buffer_left) {
          return 0;
        }

        printf("%hhu = %hhu: u8 should not change\\n", test_message_get_u8(&msg1), test_message_get_u8(&msg2));
        printf("%hu = %hu: u16 should not change\\n", test_message_get_u16(&msg1), test_message_get_u16(&msg2));
        printf("%u = %u: u32 should not change\\n", test_message_get_u32(&msg1), test_message_get_u32(&msg2));

        return 0;
      }
    source

    build_and_assert(@setup_source, roundtrip_source)
  end
end
