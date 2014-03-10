# InkFilePicker

Ruby API client for Ink File Picker (known as filepicker.io).

## Installation

Add this line to your application's Gemfile:

    gem 'ink_file_picker'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ink_file_picker

## Usage


This client mirrors part of File Picker's JavaScript API.

### Creating a client

```ruby
# Create a client which will sign URLs. You may drop secret if you have
# not enabled this feature in your developer portal for your application.
client = InkFilePicker.client(key: 'you-api-key', secret: 'your-secret')
```

### Storing a file
```ruby
response = client.store_file file_or_path, content_type
response = client.store_url 'http://www.example.com/img.jpg'
```

### Removing a file
```ruby
response = client.remove url_or_handle_name
```

### Read operations
```ruby
url = client.convert_url url_or_handle_name, w: 100, h: 100
url = client.convert_url url_or_handle_name, {w: 100, h: 100}, expiry: 10.minutes.from_now.to_i

# Adds policy and signature, if secret given when client was created.
url = client.retrieve_url url_or_handle_name
url = client.retrieve_url url_or_handle_name, expiry: 10.minutes.from_now.to_i


stats = client.stat url_or_handle_name
```


## Contributing

1. Fork it (https://github.com/Skalar/ink_file_picker/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
