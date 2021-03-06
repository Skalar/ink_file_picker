require 'spec_helper'

describe InkFilePicker::Response do
  let(:http_response_body) { '{"url": "https://www.filepicker.io/api/file/WmFxB2aSe20SGT2kzSsr", "size": 234, "type": "image/jpeg", "filename": "test.jpg", "key": "WmFxB2aSe20SGT2kzSsr_test.jpg"}' }
  let(:http_response) do
    Faraday::Response.new(
      body: http_response_body,
      status: 200
    )
  end

  subject { described_class.new http_response }

  it "has http_response" do
    expect(subject.http_response).to eq http_response
  end

  described_class::DELEGATE_TO_RESPONSE.each do |name|
    it "delegates #{name} to #http_response" do
      expect(http_response).to receive(name).and_return 'an answer'
      expect(subject.public_send name).to eq 'an answer'
    end
  end

  it "has parsed_body" do
    expect(subject.parsed_body).to eq JSON.parse http_response_body
  end

  it "returns parsed_body on to_hash" do
    expect(subject.to_hash).to eq subject.parsed_body
  end


  described_class::DELEGATE_TO_PARSED_BODY.each do |name|
    it "delegates #{name} to #parsed_body" do
      expect(subject.parsed_body).to receive(name).and_return 'an answer'
      expect(subject.public_send name).to eq 'an answer'
    end
  end

  describe "#valid?" do
    context "valid JSON as body" do
      it "is true" do
        expect(subject).to be_valid
      end
    end

    context "invalid JSON as body" do
      let(:http_response_body) { '[uuid=D93D897C42254BFB] Invalid URL file http://vp.viseno.no/vp_image.php?type=create_project_letter_head&id=1378387&ts=20140413133631&source_mediatype_code=shoebox_hq&format=jpeg&resolution=300&relative=true&scale=bestfit - timeout' }

      it "is false" do
        expect(subject).to_not be_valid
      end
    end
  end
end
