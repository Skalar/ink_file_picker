require 'bundler/setup'
require 'ink_file_picker'
require 'webmock'

WebMock.disable_net_connect!

RSpec.configure do |c|
  c.treat_symbols_as_metadata_keys_with_true_values = true
end
