require 'uri'

module InkFilePicker
  # Public: Takes a file url, adds action to the path (if any), and includes params.
  class UrlBuilder
    include Assignable

    attr_accessor :file_url, :action, :params

    def initialize(attributes = {})
      assign attributes
    end

    def url
      url = [file_url, action].compact.join '/'
      url = [url, URI.encode_www_form(params)].join '?' if params.any?

      url
    end
    alias to_s url
  end
end
