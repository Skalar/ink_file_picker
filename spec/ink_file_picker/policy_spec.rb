require 'spec_helper'

describe InkFilePicker::Policy do
  let(:secret) { '6U5CWAU57NAHDC2ICXQKMXYZ4Q' }

  subject do
    described_class.new(
      secret: secret,
      call: 'read',
      expiry: 1394363896
    )
  end

  its(:policy) { should eq 'eyJleHBpcnkiOjEzOTQzNjM4OTYsImNhbGwiOiJyZWFkIn0=' }
  its(:signature) { should eq '4c50ca71d9e123274a01eb00a7facd52069e07c2e9312517f55bf1b94447792e' }

  describe "#to_hash" do
    it "contains policy and signature when secret is given" do
      expect(subject.to_hash).to eq({
        policy: subject.policy,
        signature: subject.signature
      })
    end

    it "returns an empty hash when no secret is given" do
      subject.secret = nil
      expect(subject.to_hash).to eq({})
    end
  end
end
