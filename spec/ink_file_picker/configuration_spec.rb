require 'spec_helper'

describe InkFilePicker::Configuration do
  let(:attributes) do
    {
      key: 'key',
      secret: 'secret'
    }
  end

  subject { described_class.new attributes }

  its(:key) { should eq 'key' }
  its(:secret) { should eq 'secret' }
  its(:default_expiry) { should eq 600 }
  its(:cdn_url) { should eq 'https://www.filepicker.io/api/file/' }

  describe "#initialize" do
    it "fails when no key is given" do
      expect { described_class.new }.to raise_error ArgumentError
    end
  end
end
