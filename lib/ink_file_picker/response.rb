module InkFilePicker
  class Response
    attr_reader :http_response

    delegate :[], to: :parsed_body
    delegate :success?, to: :http_response

    def initialize(http_response)
      @http_response = http_response
    end

    def parsed_body
      @parsed_body ||= JSON.parse http_response.body
    end
  end
end
