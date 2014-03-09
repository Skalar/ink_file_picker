require 'spec_helper'

describe InkFilePicker::FileHandle do
  let(:cdn_url) { 'https://www.filepicker.io/api/file/' }
  let(:handle) { 'PHqJHHWpRAGUsIfyx0og' }
  let(:url) { "https://www.filepicker.io/api/file/#{handle}" }


  it "lets an URL pass through without modifications" do
    expect(described_class.new(url, cdn_url).url).to eq url
  end

  it "builds a file URL given only a file handle" do
    expect(described_class.new(handle, cdn_url).url).to eq url
  end
end
