class TestMessage < AdkProtocol::Message
  unsigned :u8,  8,  "8-bit unsigned field"
  unsigned :u16, 16, "16-bit unsigned field"
  unsigned :u32, 32, "32-bit unsigned field"
end
