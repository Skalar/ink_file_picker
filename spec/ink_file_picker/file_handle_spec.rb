require 'spec_helper'

describe InkFilePicker::FileHandle do
  let(:cdn_url) { 'https://www.filepicker.io/api/file/' }
  let(:handle) { 'PHqJHHWpRAGUsIfyx0og' }
  let(:url) { "https://www.filepicker.io/api/file/#{handle}" }


  describe "#url" do
    it "url passes through if the cdn url is the same as given URL" do
      expect(described_class.new(url, cdn_url).url).to eq url
    end

    it "builds a file URL given only a file handle" do
      expect(described_class.new(handle, cdn_url).url).to eq url
    end

    it "ensures that we use CDN" do
      expect(described_class.new(url, 'http://cdn.com/').url).to eq "http://cdn.com/#{handle}"
    end
  end

  describe "handle" do
    it "returns expected handle from URL" do
      expect(described_class.new(url, cdn_url).handle).to eq handle
    end
  end
end
