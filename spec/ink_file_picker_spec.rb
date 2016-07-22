require 'spec_helper'

describe InkFilePicker do
  describe ".client" do
    it "takes given arguments and initializes a client" do
      client = double
      attributes = {some: 'attributes'}

      expect(InkFilePicker::Client).to receive(:new).with(attributes).and_return client

      expect(described_class.client(attributes)).to eq client
    end
  end
end
