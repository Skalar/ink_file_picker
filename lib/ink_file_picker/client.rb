require "faraday"

module InkFilePicker
  class Client
    attr_accessor :configuration

    def initialize(configuration)
      self.configuration = Configuration.new configuration
    end


    # Public: Store a file from given URL.
    #
    # url                 - URL to resource
    # policy_attributes   - If you use security policies you may send in for instance {expire: 10.minutes.from_now} here
    #
    # Returns a hash representing the response where you can read for instance 'url'
    def store_url(url, policy_attributes = {})
      params = {key: configuration.key}

      add_policy_to params, from: policy_attributes, ensure_included: {call: 'store'}

      response = http_connection.post configuration.store_path do |request|
        request.params = params
        request.body = {url: url}
      end

      inspect_response_for_errors! response

      JSON.parse response.body
    end

    # Public: Store a file from given local file or path.
    #
    # file_or_path        - File or path to file
    # content_type        - The file's content type
    # filename            - The file's name, optional
    # policy_attributes   - If you use security policies you may send in for instance {expire: 10.minutes.from_now} here
    #
    # Returns a hash representing the response where you can read for instance 'url'
    def store_file(file_or_path, content_type, filename = nil, policy_attributes = {})
      file_upload = Faraday::UploadIO.new file_or_path, content_type, filename
      params = {key: configuration.key}

      add_policy_to params, from: policy_attributes, ensure_included: {call: 'store'}

      response = http_connection.post configuration.store_path do |request|
        request.params = params
        request.body = {fileUpload: file_upload}
      end

      inspect_response_for_errors! response
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

      inspect_response_for_errors! response
      response.success?
    end


    # Public: Returns short stat for a file
    #
    # handle_or_url       - The handle or URL to the file
    # params              - Request params, like {width: true, height: true} to get width and height info. May be empty for default response
    # policy_attributes   - If you use security policies you may send in for instance {expire: 10.minutes.from_now} here
    #
    # Returns hash of headers returned from file picker or false if request was unsuccessful
    def stat(handle_or_url, params = {}, policy_attributes = {})
      response = http_connection.get stat_url(handle_or_url, params, policy_attributes)

      inspect_response_for_errors! response
      JSON.parse response.body
    end

    # Public: Generates a you can use for removing an asset on file picker.
    #
    # handle_or_url       - The handle or URL to the file
    # policy_attributes   - If you use security policies you may send in for instance {expire: 10.minutes.from_now} here
    #
    # Returns a URL to the converted image
    def remove_url(handle_or_url, policy_attributes = {})
      generate_url handle_or_url, {key: configuration.key}, policy_attributes, call: 'remove'
    end

    # Public: Generates a convert URL for given file.
    #
    # handle_or_url       - The handle or URL to the file
    # params              - Convert params, like {w: 100, h:100}
    # policy_attributes   - If you use security policies you may send in for instance {expire: 10.minutes.from_now} here
    #
    # Returns a URL to the converted image
    def convert_url(handle_or_url, params = {}, policy_attributes = {})
      generate_url handle_or_url, params, policy_attributes, call: 'convert', url_action: 'convert'
    end


    # Public: Generates a URL for a given file
    #
    # handle_or_url       - The handle or URL to the file
    # params              - Params to be added as get params, like {cache: true}
    # policy_attributes   - If you use security policies you may send in for instance {expire: 10.minutes.from_now} here
    #
    # This method is not that usefull unless you have enabled security policy
    #
    # Returns a URL to the image
    def retrieve_url(handle_or_url, params = {}, policy_attributes = {})
      generate_url handle_or_url, params, policy_attributes, call: 'read'
    end


    # Public: Generates a stat URL for a given file
    #
    # handle_or_url       - The handle or URL to the file
    # policy_attributes   - If you use security policies you may send in for instance {expire: 10.minutes.from_now} here
    #
    # Returns a URL to the image you can do a HEAD request to in order to get stats
    def stat_url(handle_or_url, params, policy_attributes = {})
      generate_url handle_or_url, params, policy_attributes, call: 'stat', url_action: 'metadata'
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





    def http_connection
      @http_connection ||= Faraday.new(url: configuration.filepicker_url) do |builder|
        builder.request :multipart
        builder.request :url_encoded
        builder.adapter configuration.http_adapter || Faraday.default_adapter
      end
    end


    private

    def generate_url(handle_or_url, params, policy_attributes, options)
      file_handle = FileHandle.new handle_or_url, configuration.cdn_url

      add_policy_to params, from: policy_attributes, ensure_included: {handle: file_handle.handle, call: options[:call]}

      url = UrlBuilder.new(file_url: file_handle.url, action: options[:url_action], params: params).to_s
    end

    def add_policy_to(params, options = {})
      policy_attributes = (options[:from] || {}).merge options[:ensure_included]
      params.merge! policy(policy_attributes)
    end

    # Private: Inspects response for error and raise a InkFilePicker error if client/server error.
    def inspect_response_for_errors!(response)
      unless response.success?
        case response.status
        when 400...500
          fail ClientError.new response.body, response
        when 500...600
          fail ServerError.new response.body, response
        else
          fail Error, "Response was neither a success, nor within http status 400...600. Response was: '#{response.inspect}'."
        end
      end
    end
  end
end
