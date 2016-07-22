require 'spec_helper'

describe InkFilePicker::Configuration do
  let(:attributes) do
    {
      key: 'key',
      secret: 'secret'
    }
  end

  subject { described_class.new attributes }

  it { expect(subject.key).to eq 'key' }
  it { expect(subject.secret).to eq 'secret' }
  it { expect(subject.default_expiry).to eq 600 }
  it { expect(subject.cdn_url).to eq 'https://www.filepicker.io/api/file/' }

  describe "#initialize" do
    it "fails when no key is given" do
      expect { described_class.new }.to raise_error ArgumentError
    end
  end
end
