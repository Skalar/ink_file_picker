module InkFilePicker
  class Client
    attr_accessor :configuration

    def initialize(configuration)
      self.configuration = Configuration.new configuration
    end

    def convert(handle_or_url, params = {})
      handle = FileHandle.new handle_or_url, configuration.cdn_url
      UrlBuilder.new(handle.url, :convert, params).to_s
    end



    def policy(attributes)
      attributes.reverse_merge!(
        secret: configuration.secret,
        expiry: Time.now.to_i + configuration.default_expiry
      )

      Policy.new attributes
    end
  end
end
