require 'forwardable'
require 'json'

module InkFilePicker
  # Public: Simple decorator class for response.
  #
  # Decorates the response with hash like access to the
  # parsed body, which is expected to be JSON.
  class Response
    extend Forwardable

    DELEGATE_TO_RESPONSE = %w[
      success? status headers body finished?
    ]

    DELEGATE_TO_PARSED_BODY = %w[
      to_hash each
    ]

    attr_reader :http_response

    def_delegators :http_response,  *DELEGATE_TO_RESPONSE
    def_delegators :parsed_body,    *DELEGATE_TO_PARSED_BODY


    def initialize(http_response)
      @http_response = http_response
    end

    def [](key)
      parsed_body[key.to_s]
    end

    def parsed_body
      @parsed_body ||= JSON.parse http_response.body
    end

    def valid?
      body == 'success' ||
      parsed_body
    rescue JSON::ParserError
      false
    end
  end
end
