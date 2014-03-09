module InkFilePicker
  class Client
    attr_accessor :configuration

    def initialize(configuration)
      self.configuration = Configuration.new configuration
    end


    def convert(handle_or_url, params = {}, policy_attributes = {})
      file_handle = FileHandle.new handle_or_url, configuration.cdn_url

      add_policy_to params, from: policy_attributes, ensure_included: {handle: file_handle.handle, call: 'convert'}

      UrlBuilder.new(file_url: file_handle.url, action: :convert, params: params).to_s
    end

    def retrieve(handle_or_url, policy_attributes = {})
      file_handle = FileHandle.new handle_or_url, configuration.cdn_url

      params = {}
      add_policy_to params, from: policy_attributes, ensure_included: {handle: file_handle.handle, call: 'read'}

      UrlBuilder.new(file_url: file_handle.url, params: params).to_s
    end





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
