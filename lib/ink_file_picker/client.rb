module InkFilePicker
  class Client
    attr_accessor :configuration

    def initialize(configuration)
      self.configuration = Configuration.new configuration
    end


    def policy(attributes)
      attributes.reverse_merge!(
        expiry: Time.now.to_i + configuration.default_expiry
      )

      Policy.new attributes
    end
  end
end
