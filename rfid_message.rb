class RfidMessage < AdkProtocol::Message
  unsigned :parity_ok,  8, "Boolean for if parity is OK or not"
  unsigned :card_id,   32, "Card identifier that we read"
end
