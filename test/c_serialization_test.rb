require File.absolute_path(File.dirname(__FILE__) + '/test_helpers')

require 'test_message'

class CSerializationTest < Test::Unit::TestCase
  include CBuilder

  setup :setup_c_source, :before => :append

  def test_build
    noop_binary = build(c_source, 'int main() { return 0; }')
    assert_true(File.exist?(noop_binary))
    assert_true(system(noop_binary))
  end

  def test_roundtrip_unsigned
    roundtrip_source = <<-source.gsub(/^ {6}/, '').with_lineno
      int main() {
        test_message_t msg1 = {0}, msg2;
        char buffer[sizeof(test_message_t)], *buffer_left;

        msg1.u8  = #{0b11000011};
        msg1.u16 = #{0b1010101001010101};
        msg1.u32 = #{0b11111111000000001000000101111110};

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

        printf("%hhu = %hhu: u8 should not change\\n", msg1.u8, msg2.u8);
        printf("%hu  = %hu : u16 should not change\\n", msg1.u16, msg2.u16);
        printf("%u   = %u  : u32 should not change\\n", msg1.u32, msg2.u32);

        return 0;
      }
    source

    build_and_assert(c_source, roundtrip_source)
  end

  def test_roundtrip_signed
    roundtrip_source = <<-source.gsub(/^ {6}/, '').with_lineno
      int main() {
        test_message_t msg1 = {0}, msg2;
        char buffer[sizeof(test_message_t)], *buffer_left;

        msg1.s8 = -128;
        msg1.s16 = -32768;
        msg1.s32 = (-2147483647-1);

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

        printf("%hhi = %hhi: s8 should not change\\n", msg1.s8, msg2.s8);
        printf("%hi  = %hi : s16 should not change\\n", msg1.s16, msg2.s16);
        printf("%i   = %i  : s32 should not change\\n", msg1.s32, msg2.s32);

        return 0;
      }
    source

    build_and_assert(c_source, roundtrip_source)
  end
end
