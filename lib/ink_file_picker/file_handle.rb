module InkFilePicker
  class FileHandle
    attr_accessor :handle_or_url, :cdn_url

    def initialize(handle_or_url, cdn_url)
      self.cdn_url = cdn_url
      self.handle_or_url = handle_or_url
    end

    def url
      if handle_or_url =~ %r{\Ahttps?://}
        handle_or_url
      else
        build_url_from_handle
      end
    end



    private

    def build_url_from_handle
      joins_with = cdn_url.ends_with?('/') ? '' : '/'
      [cdn_url, handle_or_url].join joins_with
    end
  end
end
