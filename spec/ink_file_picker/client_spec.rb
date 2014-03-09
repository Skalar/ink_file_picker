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

  describe "#policy" do
    let(:policy_attributes) { {call: 'read'} }
    let(:policy) { double }

    describe "expiry" do
      context "is given" do
        it "uses given value" do
          InkFilePicker::Policy.should_receive(:new).with(hash_including(call: 'read', expiry: 60)).and_return policy

          expect(subject.policy policy_attributes.merge(expiry: 60)).to eq policy
        end
      end

      context "not given" do
        before { Time.stub_chain(:now, :to_i).and_return 1 }

        it "uses default_expiry from config" do
          subject.configuration.stub(:default_expiry).and_return 600

          InkFilePicker::Policy.should_receive(:new).with(hash_including(call: 'read', expiry: 601)).and_return policy

          expect(subject.policy policy_attributes).to eq policy
        end
      end
    end
  end
end
