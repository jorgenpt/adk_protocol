class TestMessage < AdkProtocol::Message
  unsigned :u8,  8,  "8-bit unsigned field"
  unsigned :u16, 16, "16-bit unsigned field"
  unsigned :u32, 32, "32-bit unsigned field"
  signed   :s8,  8,  "8-bit signed field"
  signed   :s16, 16, "16-bit signed field"
  signed   :s32, 32, "32-bit signed field"
end
