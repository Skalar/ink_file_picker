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
end
