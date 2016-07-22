require 'base64'
require 'openssl'

module InkFilePicker
  class Policy
    include Assignable

    POLICY_ATTRIBUTES = %w[expiry call handle max_size min_size path container].freeze

    attr_accessor :secret, *POLICY_ATTRIBUTES

    def initialize(attributes)
      assign attributes
    end



    def policy
      Base64.urlsafe_encode64 policy_json
    end

    def signature
      OpenSSL::HMAC.hexdigest 'sha256', secret, policy
    end


    def to_hash
      return {} if Utils::Blank.blank? secret

      {
        policy: policy,
        signature: signature
      }
    end



    def policy_json
      out = {}

      POLICY_ATTRIBUTES.each do |attr_name|
        if value = self[attr_name] and !Utils::Blank.blank?(value)
          out[attr_name] = value
        end
      end

      out.to_json
    end
  end
end
