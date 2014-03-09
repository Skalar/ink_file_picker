require "faraday"

module InkFilePicker
  class Client
    attr_accessor :configuration

    def initialize(configuration)
      self.configuration = Configuration.new configuration
    end


    # Public: Store a file.
    #
    # file_or_url         - An handle to a local file or a URL as string
    # policy_attributes   - If you use security policies you may send in for instance {expire: 10.minutes.from_now} here
    #
    # Returns a hash representing the response where you can read 'url'
    def store(file_or_url, policy_attributes = {})
      response = case file_or_url
        when File
          fail ArgumentError, "Not implemented file support, yet."
        when String
          store_url file_or_url, policy_attributes
        end

      JSON.parse response.body
    end

    # Public: Removes a file from file picker.
    #
    # handle_or_url       - The handle or URL to the file
    # policy_attributes   - If you use security policies you may send in for instance {expire: 10.minutes.from_now} here
    #
    # Returns boolean value
    def remove(handle_or_url, policy_attributes = {})
      response = http_connection.delete remove_url(handle_or_url, policy_attributes)
      response.success?
    end

    # Public: Generates a you can use for removing an asset on file picker.
    #
    # handle_or_url       - The handle or URL to the file
    # policy_attributes   - If you use security policies you may send in for instance {expire: 10.minutes.from_now} here
    #
    # Returns a URL to the converted image
    def remove_url(handle_or_url, policy_attributes = {})
      file_handle = FileHandle.new handle_or_url, configuration.cdn_url

      params = {key: configuration.key}
      add_policy_to params, from: policy_attributes, ensure_included: {handle: file_handle.handle, call: 'remove'}

      url = UrlBuilder.new(file_url: file_handle.url, params: params).to_s
    end

    # Public: Generates a convert URL for given file.
    #
    # handle_or_url       - The handle or URL to the file
    # params              - Convert params, like {w: 100, h:100}
    # policy_attributes   - If you use security policies you may send in for instance {expire: 10.minutes.from_now} here
    #
    # Returns a URL to the converted image
    def convert_url(handle_or_url, params = {}, policy_attributes = {})
      file_handle = FileHandle.new handle_or_url, configuration.cdn_url

      add_policy_to params, from: policy_attributes, ensure_included: {handle: file_handle.handle, call: 'convert'}

      UrlBuilder.new(file_url: file_handle.url, action: :convert, params: params).to_s
    end


    # Public: Generates a URL for a given file
    #
    # handle_or_url       - The handle or URL to the file
    # policy_attributes   - If you use security policies you may send in for instance {expire: 10.minutes.from_now} here
    #
    # This method is not that usefull unless you have enabled security policy
    #
    # Returns a URL to the image
    def retrieve_url(handle_or_url, policy_attributes = {})
      file_handle = FileHandle.new handle_or_url, configuration.cdn_url

      params = {}
      add_policy_to params, from: policy_attributes, ensure_included: {handle: file_handle.handle, call: 'read'}

      UrlBuilder.new(file_url: file_handle.url, params: params).to_s
    end





    # Public: Creates a policy with default configuration set in this client.
    #
    # Returns Policy object
    def policy(attributes)
      attributes.reverse_merge!(
        secret: configuration.secret,
        expiry: Time.now.to_i + configuration.default_expiry
      )

      Policy.new attributes
    end





    private

    def http_connection
      @http_connection ||= Faraday.new(url: configuration.filepicker_url) do |builder|
        builder.request :multipart
        builder.request :url_encoded
        builder.adapter configuration.http_adapter || Faraday.default_adapter
      end
    end

    def add_policy_to(params, options = {})
      policy_attributes = (options[:from] || {}).merge options[:ensure_included]
      params.merge! policy(policy_attributes)
    end


    def store_url(url, policy_attributes = {})
      params = {key: configuration.key}

      add_policy_to params, from: policy_attributes, ensure_included: {call: 'store'}

      http_connection.post configuration.store_path do |request|
        request.params = params
        request.body = {url: url}
      end
    end
  end
end
