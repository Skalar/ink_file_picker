module InkFilePicker
  class Configuration
    API_DEFAULTS = {
      secret: nil
    }

    attr_accessor :key, :secret

    def initialize(attributes = {})
      assign API_DEFAULTS
      assign attributes

      verify!
    end

    def []=(name, value)
      public_send "#{name}=", value
    end

    def [](name)
      public_send name
    end



    private

    def assign(attributes)
      attributes.each_pair do |name, value|
        self[name] = value
      end
    end

    def verify!
      if key.blank?
        fail ArgumentError, "An API key must be provided"
      end
    end
  end
end
