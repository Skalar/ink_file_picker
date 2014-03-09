require "ink_file_picker/version"

require "active_support/all"


module InkFilePicker
  extend ActiveSupport::Autoload

  autoload :Assignable
  autoload :Configuration
  autoload :Client

  # Public: Creates a new Ink File Picker Client.
  #
  # configuration - configuration for the client with an API key
  #
  # Returns InkFilePicker::Client
  def self.client(configuration)
    Client.new configuration
  end
end
