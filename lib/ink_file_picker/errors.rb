module InkFilePicker
  module ErrorWithOriginal
    attr_reader :msg, :related

    def initialize(msg, related)
      @msg = msg
      @related = related
    end

    def to_s
      "#{self.class.name}: Message: '#{msg}'. Related object: '#{related.inspect}'."
    end
    alias inspect to_s
  end


  # Public: Base class for errors related to InkFilePicker.
  class Error < StandardError
  end

  # Public: Got a request error back trying to do a request
  #
  # This includes wire errors like timeouts etc, and server errors
  # like 5xx. Inspect error_or_response for more information.
  #
  class ServerError < Error
    include ErrorWithOriginal
  end

  # Public: Got an error where the client seems to be doing something wrong
  #
  # These errors mainly comes from http 4xx errors.
  class ClientError < Error
    include ErrorWithOriginal
  end

  # Public: When FilePicker returns 200 OK http status, but body is unexpected.
  #
  # These errors mainly comes from http status code 200, but at the same time the
  # body is not 'success' neither a parsable JSON string.
  #
  # This seem to happen, for instance when you ask File Picker to store a URL
  # and the remote server we want to download files from takes more than 5 seconds
  # before it starts sending data. At this point FilePicker returns 200 OK, with a
  # body like:
  # "[uuid=D93D897C42254BFA] Invalid URL file http://www.example.com/slow-response.jpg - timeout"
  #
  # In stead of returning this response and get a JSON::ParserError down the road
  # we fail as soon as we see something like this.
  #
  # As of writing this I don't know if this is the best solution to the situation.
  class UnexpectedResponseError < Error
  end
end
