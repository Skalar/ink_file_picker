require 'spec_helper'

describe InkFilePicker::Client do
  let(:attributes) do
    {
      key: 'key',
      secret: '6U5CWAU57NAHDC2ICXQKMXYZ4Q',
      http_adapter: :test
    }
  end

  subject { described_class.new attributes }

  describe "#store" do
    context "given a url" do
      let(:url) { 'https://s3.amazonaws.com/test.jpg' }
      let(:response) { '{"url": "https://www.filepicker.io/api/file/WmFxB2aSe20SGT2kzSsr", "size": 234, "type": "image/jpeg", "filename": "test.jpg", "key": "WmFxB2aSe20SGT2kzSsr_test.jpg"}' }

      context "without secret" do
        before { subject.configuration.secret = nil }

        it "posts to filepicker" do
          stubs = Faraday::Adapter::Test::Stubs.new do |stub|
            stub.post(subject.configuration.store_path + '?key=key', {url: url}) { [200, {}, response] }
          end

          stubbed_connection = Faraday.new do |builder|
            builder.adapter :test, stubs
          end

          subject.stub(:http_connection).and_return stubbed_connection

          response = subject.store url

          stubs.verify_stubbed_calls
          expect(response['url']).to eq 'https://www.filepicker.io/api/file/WmFxB2aSe20SGT2kzSsr'
        end
      end

      context "with secret" do
        it "includes policy and signature" do
          stubs = Faraday::Adapter::Test::Stubs.new do |stub|
            store_path = subject.configuration.store_path + '?key=key&policy=eyJleHBpcnkiOjEzOTQzNjM4OTYsImNhbGwiOiJzdG9yZSJ9&signature=60cb43bb945543d7fdbd2662ae21d5c53e28529720263619cfebc3509e820807'
            stub.post(store_path, {url: url}) { [200, {}, response] }
          end

          stubbed_connection = Faraday.new do |builder|
            builder.adapter :test, stubs
          end

          subject.stub(:http_connection).and_return stubbed_connection

          response = subject.store url, expiry: 1394363896

          stubs.verify_stubbed_calls
          expect(response['url']).to eq 'https://www.filepicker.io/api/file/WmFxB2aSe20SGT2kzSsr'
        end
      end
    end

    context "given a local file handle" do
      pending
    end
  end

  describe "#remove" do
    let(:file_url) { 'https://www.filepicker.io/api/file/WmFxB2aSe20SGT2kzSsr' }

    context "without secret" do
      before { subject.configuration.secret = nil }

      it "makes a delete request with url" do
        stubs = Faraday::Adapter::Test::Stubs.new do |stub|
          stub.delete(file_url + '?key=key') { [200, {}, 'success'] }
        end

        stubbed_connection = Faraday.new do |builder|
          builder.adapter :test, stubs
        end

        subject.stub(:http_connection).and_return stubbed_connection

        response = subject.remove file_url

        stubs.verify_stubbed_calls
        expect(response).to be_true
      end

      it "makes delete request with file handle name" do
        stubs = Faraday::Adapter::Test::Stubs.new do |stub|
          stub.delete(file_url + '?key=key') { [200, {}, 'success'] }
        end

        stubbed_connection = Faraday.new do |builder|
          builder.adapter :test, stubs
        end

        subject.stub(:http_connection).and_return stubbed_connection

        response = subject.remove 'WmFxB2aSe20SGT2kzSsr'

        stubs.verify_stubbed_calls
        expect(response).to be_true
      end
    end

    context "with secret" do
      it "includes policy and signature" do
        stubs = Faraday::Adapter::Test::Stubs.new do |stub|
          stub.delete(file_url + '?key=key&policy=eyJleHBpcnkiOjEzOTQzNjM4OTYsImNhbGwiOiJyZW1vdmUiLCJoYW5kbGUiOiJXbUZ4QjJhU2UyMFNHVDJrelNzciJ9&signature=a557d55a680892235619ff0bec6c7254fbb8088e53a53d923b4fad1d39df3955') { [200, {}, 'success'] }
        end

        stubbed_connection = Faraday.new do |builder|
          builder.adapter :test, stubs
        end

        subject.stub(:http_connection).and_return stubbed_connection

        response = subject.remove file_url, expiry: 1394363896

        stubs.verify_stubbed_calls
        expect(response).to be_true
      end
    end
  end

  describe "#convert_url" do
    let(:handle) { 'PHqJHHWpRAGUsIfyx0og' }
    let(:url) { "https://www.filepicker.io/api/file/#{handle}" }

    context "without secret" do
      before { subject.configuration.secret = nil }

      it "builds expected convert URL when given a URL" do
        expect(subject.convert_url url, w: 300, h: 200).to eq 'https://www.filepicker.io/api/file/PHqJHHWpRAGUsIfyx0og/convert?h=200&w=300'
      end

      it "builds expected convert URL when given a handle" do
        expect(subject.convert_url handle, w: 300, h: 200).to eq 'https://www.filepicker.io/api/file/PHqJHHWpRAGUsIfyx0og/convert?h=200&w=300'
      end
    end

    context "with secret" do
      it "builds expected convert URL when given a URL" do
        expect(subject.convert_url url, {w: 300, h: 200}, expiry: 1394363896).to eq 'https://www.filepicker.io/api/file/PHqJHHWpRAGUsIfyx0og/convert?h=200&policy=eyJleHBpcnkiOjEzOTQzNjM4OTYsImNhbGwiOiJjb252ZXJ0IiwiaGFuZGxlIjoiUEhxSkhIV3BSQUdVc0lmeXgwb2cifQ%3D%3D&signature=b370d4ae604c7917c169fe5b10a6274683bb82056c7b80993a7601d486b89d22&w=300'
      end
    end
  end

  describe "#retrieve_url" do
    let(:handle) { 'PHqJHHWpRAGUsIfyx0og' }
    let(:url) { "https://www.filepicker.io/api/file/#{handle}" }

    context "without secret" do
      before { subject.configuration.secret = nil }

      it "builds expected retrieve URL when given a URL" do
        expect(subject.retrieve_url url).to eq 'https://www.filepicker.io/api/file/PHqJHHWpRAGUsIfyx0og'
      end

      it "builds expected retrieve URL when given a handle" do
        expect(subject.retrieve_url handle).to eq 'https://www.filepicker.io/api/file/PHqJHHWpRAGUsIfyx0og'
      end
    end

    context "with secret" do
      it "builds expected retrieve URL when given a URL" do
        expect(subject.retrieve_url url, expiry: 1394363896).to eq 'https://www.filepicker.io/api/file/PHqJHHWpRAGUsIfyx0og?policy=eyJleHBpcnkiOjEzOTQzNjM4OTYsImNhbGwiOiJyZWFkIiwiaGFuZGxlIjoiUEhxSkhIV3BSQUdVc0lmeXgwb2cifQ%3D%3D&signature=6bba22df7390a44a13329d2f2ca8317c48317fe6612b21f957670969a074f778'
      end
    end
  end



  describe "#configuration" do
    it "has key set" do
      expect(subject.configuration.key).to eq 'key'
    end

    it "has secret set" do
      expect(subject.configuration.secret).to eq '6U5CWAU57NAHDC2ICXQKMXYZ4Q'
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
