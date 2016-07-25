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

  it { expect(subject.policy).to eq 'eyJleHBpcnkiOjEzOTQzNjM4OTYsImNhbGwiOiJyZWFkIn0=' }
  it { expect(subject.signature).to eq '4c50ca71d9e123274a01eb00a7facd52069e07c2e9312517f55bf1b94447792e' }

  describe "the policy" do
    let(:decoded) do
      JSON.parse Base64.urlsafe_decode64 subject.policy
    end

    it { expect(decoded['call']).to eq 'read' }
    it { expect(decoded['expiry']).to eq 1394363896 }

    it "ensures expiry is a number" do
      time = Time.parse("2016-01-01 00:00")
      subject.expiry = time

      decoded = JSON.parse Base64.urlsafe_decode64 subject.policy
      expect(decoded['expiry']).to eq 1451602800
    end
  end

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
