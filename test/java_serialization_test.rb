require File.absolute_path(File.dirname(__FILE__) + '/test_helpers')

if defined?(JRUBY_VERSION)
  require 'java'
end

class JavaSerializationTest < Test::Unit::TestCase
  include JavaBuilder

  setup :generate_java_source, :before => :append
  setup :build_java_source, :before => :append

  def test_build
    # We just check that build succeeds, which doesn't even require JRuby.
  end

  def import_protocol
    java_import 'com.bitspatter.adk_protocol.Message'
    java_import 'com.bitspatter.adk_protocol.TestMessage'
    java_import 'com.bitspatter.adk_protocol.MessageTypes'
    java_import 'java.nio.ByteBuffer'
  end

  def test_roundtrip_unsigned
    omit_unless(defined?(JRUBY_VERSION), "Java tests need JRuby")
    import_protocol

    buffer = ByteBuffer.allocate(TestMessage.size)

    msg1 = TestMessage.new
    msg1.u8  = 0b11000011
    msg1.u16 = 0b1010101001010101
    msg1.u32 = 0b11111111000000001000000101111110
    msg1.serialize(buffer)

    buffer.rewind
    msg2 = Message.parse(buffer)

    assert_not_nil(msg2)
    assert_equal(msg1.u8, msg2.u8)
    assert_equal(msg1.u16, msg2.u16)
    assert_equal(msg1.u32, msg2.u32)
  end

  def test_roundtrip_signed
    omit_unless(defined?(JRUBY_VERSION), "Java tests need JRuby")
    import_protocol

    buffer = ByteBuffer.allocate(TestMessage.size)

    msg1 = TestMessage.new
    msg1.s8 = java.lang.Byte::MIN_VALUE
    msg1.s16 = java.lang.Short::MIN_VALUE
    msg1.s32 = java.lang.Integer::MIN_VALUE
    msg1.serialize(buffer)

    buffer.rewind
    msg2 = Message.parse(buffer)

    assert_not_nil(msg2)
    assert_equal(msg1.s8, msg2.s8)
    assert_equal(msg1.s16, msg2.s16)
    assert_equal(msg1.s32, msg2.s32)
  end
end
