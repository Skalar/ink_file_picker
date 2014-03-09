module InkFilePicker
  class Client
    attr_accessor :configuration

    def initialize(configuration)
      self.configuration = Configuration.new configuration
    end


    # Public: Generates a convert URL for given file.
    #
    # handle_or_url       - The handle or URL to the file
    # params              - Convert params, like {w: 100, h:100}
    # policy_attributes   - If you use security policies you may send in for instance {expire: 10.minutes.from_now} here
    #
    # Returns a URL to the converted image
    def convert(handle_or_url, params = {}, policy_attributes = {})
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
    def retrieve(handle_or_url, policy_attributes = {})
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

    def add_policy_to(params, options = {})
      policy_attributes = options[:from].merge options[:ensure_included]
      params.merge! policy(policy_attributes)
    end
  end
end
