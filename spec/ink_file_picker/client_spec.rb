require 'spec_helper'
require 'uri'

describe InkFilePicker::Client do
  # Helper method, returns a hash represneting get query param
  def query_to_hash(uri)
    uri = URI.parse uri
    Hash[uri.query.split('&').map { |name_value| name_value.split('=') }]
  end

  let(:attributes) do
    {
      key: 'key',
      secret: '6U5CWAU57NAHDC2ICXQKMXYZ4Q',
      http_adapter: :test
    }
  end

  subject { described_class.new attributes }

  describe "#store_url" do
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

        allow(subject).to receive(:http_connection).and_return stubbed_connection

        response = subject.store_url url

        stubs.verify_stubbed_calls
        expect(response['url']).to eq 'https://www.filepicker.io/api/file/WmFxB2aSe20SGT2kzSsr'
        expect(response[:url]).to eq 'https://www.filepicker.io/api/file/WmFxB2aSe20SGT2kzSsr'
        expect(response.http_response).to be_a Faraday::Response
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

        allow(subject).to receive(:http_connection).and_return stubbed_connection

        response = subject.store_url url, expiry: 1394363896

        stubs.verify_stubbed_calls
        expect(response['url']).to eq 'https://www.filepicker.io/api/file/WmFxB2aSe20SGT2kzSsr'
      end

      it "handles client errors correctly" do
        stubs = Faraday::Adapter::Test::Stubs.new do |stub|
          store_path = subject.configuration.store_path + '?key=key&policy=eyJleHBpcnkiOjEzOTQzNjM4OTYsImNhbGwiOiJzdG9yZSJ9&signature=60cb43bb945543d7fdbd2662ae21d5c53e28529720263619cfebc3509e820807'
          stub.post(store_path, {url: url}) { [403, {}, '[uuid=AF614DF7F9594A87] This action has been secured by the developer of this website. Error: The signature was not valid'] }
        end

        stubbed_connection = Faraday.new do |builder|
          builder.adapter :test, stubs
        end

        allow(subject).to receive(:http_connection).and_return stubbed_connection

        expect { subject.store_url url, expiry: 1394363896 }.to raise_error InkFilePicker::ClientError
      end

      it "handles timeout error on remote server correctly" do
        response_body = "[uuid=D93D897C42254BFB] Invalid URL file http://vp.viseno.no/vp_image.php?type=create_project_letter_head&id=1378387&ts=20140413133631&source_mediatype_code=shoebox_hq&format=jpeg&resolution=300&relative=true&scale=bestfit - timeout"

        stubs = Faraday::Adapter::Test::Stubs.new do |stub|
          store_path = subject.configuration.store_path + '?key=key&policy=eyJleHBpcnkiOjEzOTQzNjM4OTYsImNhbGwiOiJzdG9yZSJ9&signature=60cb43bb945543d7fdbd2662ae21d5c53e28529720263619cfebc3509e820807'
          stub.post(store_path, {url: url}) { [200, {}, response_body] }
        end

        stubbed_connection = Faraday.new do |builder|
          builder.adapter :test, stubs
        end

        allow(subject).to receive(:http_connection).and_return stubbed_connection

        expect { subject.store_url url, expiry: 1394363896 }.to raise_error InkFilePicker::UnexpectedResponseError
      end

      it "handles server errors correctly" do
        stubs = Faraday::Adapter::Test::Stubs.new do |stub|
          store_path = subject.configuration.store_path + '?key=key&policy=eyJleHBpcnkiOjEzOTQzNjM4OTYsImNhbGwiOiJzdG9yZSJ9&signature=60cb43bb945543d7fdbd2662ae21d5c53e28529720263619cfebc3509e820807'
          stub.post(store_path, {url: url}) { [502, {}, 'Bad Gateway'] }
        end

        stubbed_connection = Faraday.new do |builder|
          builder.adapter :test, stubs
        end

        allow(subject).to receive(:http_connection).and_return stubbed_connection

        expect { subject.store_url url, expiry: 1394363896 }.to raise_error InkFilePicker::ServerError
      end
    end
  end

  describe "#store_file" do
    let(:path) { File.join(File.dirname(__FILE__), '../fixtures', 'skalar.png') }
    let(:file) { File.open path }
    let!(:file_upload) { Faraday::UploadIO.new file, 'image/png' }
    let(:response) { '{"url": "https://www.filepicker.io/api/file/WmFxB2aSe20SGT2kzSsr", "size": 234, "type": "image/jpeg", "filename": "test.jpg", "key": "WmFxB2aSe20SGT2kzSsr_test.jpg"}' }

    context "without secret" do
      before { subject.configuration.secret = nil }

      it "uploads the given file as file" do
        stubs = Faraday::Adapter::Test::Stubs.new do |stub|
          stub.post(subject.configuration.store_path + '?key=key', {fileUpload: file_upload}) { [200, {}, response] }
        end

        stubbed_connection = Faraday.new do |builder|
          builder.adapter :test, stubs
        end

        allow(subject).to receive(:http_connection).and_return stubbed_connection
        allow(Faraday::UploadIO).to receive(:new).and_return file_upload # Need same object, so request equals the stub

        response = subject.store_file file, 'image/png'

        stubs.verify_stubbed_calls
        expect(response['url']).to eq 'https://www.filepicker.io/api/file/WmFxB2aSe20SGT2kzSsr'
      end

      it "uploads the given file as path" do
        stubs = Faraday::Adapter::Test::Stubs.new do |stub|
          stub.post(subject.configuration.store_path + '?key=key', {fileUpload: file_upload}) { [200, {}, response] }
        end

        stubbed_connection = Faraday.new do |builder|
          builder.adapter :test, stubs
        end

        allow(subject).to receive(:http_connection).and_return stubbed_connection
        allow(Faraday::UploadIO).to receive(:new).and_return file_upload # Need same object, so request equals the stub

        response = subject.store_file path, 'image/png'

        stubs.verify_stubbed_calls
        expect(response['url']).to eq 'https://www.filepicker.io/api/file/WmFxB2aSe20SGT2kzSsr'
      end
    end

    context "with secret" do
      it "uploads the given file as file" do
        stubs = Faraday::Adapter::Test::Stubs.new do |stub|
          stub.post(subject.configuration.store_path + '?key=key&policy=eyJleHBpcnkiOjEzOTQzNjM4OTYsImNhbGwiOiJzdG9yZSJ9&signature=60cb43bb945543d7fdbd2662ae21d5c53e28529720263619cfebc3509e820807', {fileUpload: file_upload}) { [200, {}, response] }
        end

        stubbed_connection = Faraday.new do |builder|
          builder.adapter :test, stubs
        end

        allow(subject).to receive(:http_connection).and_return stubbed_connection
        allow(Faraday::UploadIO).to receive(:new).and_return file_upload # Need same object, so request equals the stub

        response = subject.store_file file, 'image/png', nil, expiry: 1394363896

        stubs.verify_stubbed_calls
        expect(response['url']).to eq 'https://www.filepicker.io/api/file/WmFxB2aSe20SGT2kzSsr'
      end

      it "handles client errors correctly" do
        stubs = Faraday::Adapter::Test::Stubs.new do |stub|
          store_path = subject.configuration.store_path + '?key=key&policy=eyJleHBpcnkiOjEzOTQzNjM4OTYsImNhbGwiOiJzdG9yZSJ9&signature=60cb43bb945543d7fdbd2662ae21d5c53e28529720263619cfebc3509e820807'
          stub.post(store_path) { [403, {}, '[uuid=AF614DF7F9594A87] This action has been secured by the developer of this website. Error: The signature was not valid'] }
        end

        stubbed_connection = Faraday.new do |builder|
          builder.adapter :test, stubs
        end

        allow(subject).to receive(:http_connection).and_return stubbed_connection

        expect { subject.store_file file, 'image/png', nil, expiry: 1394363896 }.to raise_error InkFilePicker::ClientError
      end

      it "handles server errors correctly" do
        stubs = Faraday::Adapter::Test::Stubs.new do |stub|
          store_path = subject.configuration.store_path + '?key=key&policy=eyJleHBpcnkiOjEzOTQzNjM4OTYsImNhbGwiOiJzdG9yZSJ9&signature=60cb43bb945543d7fdbd2662ae21d5c53e28529720263619cfebc3509e820807'
          stub.post(store_path) { [502, {}, 'Bad Gateway'] }
        end

        stubbed_connection = Faraday.new do |builder|
          builder.adapter :test, stubs
        end

        allow(subject).to receive(:http_connection).and_return stubbed_connection

        expect { subject.store_file file, 'image/png', nil, expiry: 1394363896 }.to raise_error InkFilePicker::ServerError
      end
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

        allow(subject).to receive(:http_connection).and_return stubbed_connection

        response = subject.remove file_url

        stubs.verify_stubbed_calls
        expect(response).to be_truthy
      end

      it "makes delete request with file handle name" do
        stubs = Faraday::Adapter::Test::Stubs.new do |stub|
          stub.delete(file_url + '?key=key') { [200, {}, 'success'] }
        end

        stubbed_connection = Faraday.new do |builder|
          builder.adapter :test, stubs
        end

        allow(subject).to receive(:http_connection).and_return stubbed_connection

        response = subject.remove 'WmFxB2aSe20SGT2kzSsr'

        stubs.verify_stubbed_calls
        expect(response).to be_truthy
      end

      it "handles server errors correctly" do
        stubs = Faraday::Adapter::Test::Stubs.new do |stub|
          stub.delete(file_url + '?key=key') { [502, {}, 'Bad Gateway'] }
        end

        stubbed_connection = Faraday.new do |builder|
          builder.adapter :test, stubs
        end

        allow(subject).to receive(:http_connection).and_return stubbed_connection

        expect { subject.remove 'WmFxB2aSe20SGT2kzSsr' }.to raise_error InkFilePicker::ServerError
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

        allow(subject).to receive(:http_connection).and_return stubbed_connection

        response = subject.remove file_url, expiry: 1394363896

        stubs.verify_stubbed_calls
        expect(response).to be_truthy
      end
    end
  end

  describe "#stat" do
    let(:file_url) { 'https://www.filepicker.io/api/file/WmFxB2aSe20SGT2kzSsr' }

    it "handles server errors correctly" do
      stubs = Faraday::Adapter::Test::Stubs.new do |receive|
        receive.get(file_url + '/metadata') { [502, {}, 'Bad Gateway'] }
      end

      stubbed_connection = Faraday.new do |builder|
        builder.adapter :test, stubs
      end

      allow(subject).to receive(:http_connection).and_return stubbed_connection

      expect { subject.stat 'WmFxB2aSe20SGT2kzSsr' }.to raise_error InkFilePicker::ServerError
    end

    context "with secret" do
      it "includes policy and signature" do
        stubs = Faraday::Adapter::Test::Stubs.new do |stub|
          stub.get(file_url + '/metadata' + '?policy=eyJleHBpcnkiOjEzOTQzNjM4OTYsImNhbGwiOiJzdGF0IiwiaGFuZGxlIjoiV21GeEIyYVNlMjBTR1Qya3pTc3IifQ%3D%3D&signature=d70d11f59750903c628f4e35ecc15ef504d71b1ed104c653fe57b2231a7d667c') do
            [200, {}, '{"mimetype": "image/jpeg", "uploaded": 13.0}']
          end
        end

        stubbed_connection = Faraday.new do |builder|
          builder.adapter :test, stubs
        end

        allow(subject).to receive(:http_connection).and_return stubbed_connection

        response = subject.stat file_url, {}, expiry: 1394363896

        stubs.verify_stubbed_calls
        expect(response['uploaded']).to eq 13.0
      end

      it "forwards get params" do
        stubs = Faraday::Adapter::Test::Stubs.new do |stub|
          stub.get(file_url + '/metadata' + '?heigth=true&policy=eyJleHBpcnkiOjEzOTQzNjM4OTYsImNhbGwiOiJzdGF0IiwiaGFuZGxlIjoiV21GeEIyYVNlMjBTR1Qya3pTc3IifQ%3D%3D&signature=d70d11f59750903c628f4e35ecc15ef504d71b1ed104c653fe57b2231a7d667c&width=true') do
            [200, {}, '{"width": 100, "height": 100}']
          end
        end

        stubbed_connection = Faraday.new do |builder|
          builder.adapter :test, stubs
        end

        allow(subject).to receive(:http_connection).and_return stubbed_connection

        response = subject.stat file_url, {width: true, heigth: true}, expiry: 1394363896

        stubs.verify_stubbed_calls
        expect(response['width']).to eq 100
      end
    end
  end

  describe "#convert_url" do
    let(:handle) { 'PHqJHHWpRAGUsIfyx0og' }
    let(:url) { "https://www.filepicker.io/api/file/#{handle}" }

    context "without secret" do
      before { subject.configuration.secret = nil }

      it "builds expected convert URL when given a URL" do
        converted_url = subject.convert_url url, w: 300, h: 200

        expect(converted_url).to start_with 'https://www.filepicker.io/api/file/PHqJHHWpRAGUsIfyx0og/convert?'
        expect(query_to_hash converted_url).to include({
          "h" => "200",
          "w" => "300"
        })
      end

      it "builds expected convert URL when given a handle" do
        converted_url = subject.convert_url handle, w: 300, h: 200

        expect(converted_url).to start_with 'https://www.filepicker.io/api/file/PHqJHHWpRAGUsIfyx0og/convert?'
        expect(query_to_hash converted_url).to include({
          "h" => "200",
          "w" => "300"
        })
      end
    end

    context "with secret" do
      it "builds expected convert URL when given a URL" do
        converted_url = subject.convert_url url, {w: 300, h: 200}, expiry: 1394363896

        expect(converted_url).to start_with 'https://www.filepicker.io/api/file/PHqJHHWpRAGUsIfyx0og/convert?'
        expect(query_to_hash converted_url).to include({
          "h" => "200",
          "w" => "300",
          "policy" => "eyJleHBpcnkiOjEzOTQzNjM4OTYsImNhbGwiOiJjb252ZXJ0IiwiaGFuZGxlIjoiUEhxSkhIV3BSQUdVc0lmeXgwb2cifQ%3D%3D",
          "signature" => "b370d4ae604c7917c169fe5b10a6274683bb82056c7b80993a7601d486b89d22"
        })
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

      it "can include params like cache set to true" do
        expect(subject.retrieve_url handle, cache: true).to eq 'https://www.filepicker.io/api/file/PHqJHHWpRAGUsIfyx0og?cache=true'
      end
    end

    context "with secret" do
      it "builds expected retrieve URL when given a URL" do
        expect(subject.retrieve_url url, {}, expiry: 1394363896).to eq 'https://www.filepicker.io/api/file/PHqJHHWpRAGUsIfyx0og?policy=eyJleHBpcnkiOjEzOTQzNjM4OTYsImNhbGwiOiJyZWFkIiwiaGFuZGxlIjoiUEhxSkhIV3BSQUdVc0lmeXgwb2cifQ%3D%3D&signature=6bba22df7390a44a13329d2f2ca8317c48317fe6612b21f957670969a074f778'
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
          expect(InkFilePicker::Policy).to receive(:new).with(hash_including(call: 'read', expiry: 60)).and_return policy

          expect(subject.policy policy_attributes.merge(expiry: 60)).to eq policy
        end
      end

      context "not given" do
        let(:the_time) { double :time, to_i: 1 }
        before { allow(Time).to receive(:now).and_return the_time }

        it "uses default_expiry from config" do
          allow(subject.configuration).to receive(:default_expiry).and_return 600

          expect(InkFilePicker::Policy).to receive(:new).with(hash_including(call: 'read', expiry: 601)).and_return policy

          expect(subject.policy policy_attributes).to eq policy
        end
      end
    end
  end
end
