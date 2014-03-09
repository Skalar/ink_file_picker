require 'spec_helper'

describe InkFilePicker::Client do
  let(:attributes) do
    {
      key: 'key',
      secret: 'secret'
    }
  end

  subject { described_class.new attributes }

  describe "#configuration" do
    it "has key set" do
      expect(subject.configuration.key).to eq 'key'
    end

    it "has secret set" do
      expect(subject.configuration.secret).to eq 'secret'
    end
  end
end
