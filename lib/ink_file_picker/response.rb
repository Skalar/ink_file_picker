module InkFilePicker
  # Public: Simple decorator class for response.
  #
  # Decorates the response with hash like access to the
  # parsed body, which is expected to be JSON.
  class Response
    attr_reader :http_response

    delegate :success?, to: :http_response

    def initialize(http_response)
      @http_response = http_response
    end

    def [](key)
      parsed_body[key.to_s]
    end

    def parsed_body
      @parsed_body ||= JSON.parse http_response.body
    end
    alias to_hash parsed_body
  end
end
