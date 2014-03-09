module InkFilePicker
  class UrlBuilder
    attr_accessor :file_url, :action, :params

    def initialize(file_url, action, params)
      self.file_url = file_url
      self.action = action
      self.params = params
    end

    def url
      url = [file_url, action].join '/'
      [url, params.to_param].join '?'
    end
    alias to_s url
  end
end
