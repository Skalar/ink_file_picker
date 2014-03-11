require 'uri'

module InkFilePicker
  # Public: Simple class for working with file URL and file handles.
  #
  # Does conversions like url to handle and from a handle to url
  class FileHandle
    attr_accessor :handle, :url, :cdn_url

    def initialize(handle_or_url, cdn_url)
      self.cdn_url = cdn_url
      self.handle = extract_handle handle_or_url
      self.url = build_url_from_handle
    end



    private

    def build_url_from_handle
      joins_with = cdn_url.ends_with?('/') ? '' : '/'
      [cdn_url, handle].join joins_with
    end

    def extract_handle(handle_or_url)
      uri = URI.parse handle_or_url
      uri.path.split('/').last
    rescue URI::InvalidURIError
      handle_or_url
    end
  end
end
