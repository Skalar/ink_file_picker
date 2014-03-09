module InkFilePicker
  class Configuration
    include Assignable

    API_DEFAULTS = {
      secret: nil,
      default_expiry: 600, # in 10 hours
      cdn_url: 'https://www.filepicker.io/api/file/',
      filepicker_url: 'https://www.filepicker.io',
      store_path: '/api/store/S3',
      http_adapter: :net_http
    }

    attr_accessor :key, :secret, :default_expiry, :cdn_url, :filepicker_url, :store_path, :http_adapter

    def initialize(attributes = {})
      assign API_DEFAULTS
      assign attributes

      verify!
    end


    private

    def verify!
      if key.blank?
        fail ArgumentError, "An API key must be provided"
      end
    end
  end
end
