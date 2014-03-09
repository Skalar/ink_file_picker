module InkFilePicker
  class Configuration
    include Assignable

    API_DEFAULTS = {
      secret: nil
    }

    attr_accessor :key, :secret

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
