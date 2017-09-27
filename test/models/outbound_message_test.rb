require "test_helper"

describe OutboundMessage do
  let(:outbound_message) { OutboundMessage.new }

  it "must be valid" do
    value(outbound_message).must_be :valid?
  end
end
