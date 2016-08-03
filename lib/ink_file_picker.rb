require "ink_file_picker/version"

require "ink_file_picker/errors"
require "ink_file_picker/assignable"
require "ink_file_picker/configuration"
require "ink_file_picker/file_handle"
require "ink_file_picker/url_builder"
require "ink_file_picker/response"
require "ink_file_picker/client"
require "ink_file_picker/policy"
require "ink_file_picker/utils"

module InkFilePicker
  # Public: Creates a new Ink File Picker Client.
  #
  # configuration - configuration for the client with an API key
  #
  # Returns InkFilePicker::Client
  def self.client(configuration)
    Client.new configuration
  end
end
