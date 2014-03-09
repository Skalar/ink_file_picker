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
response = client.store a_file_handle
response = client.store 'http://www.example.com/img.jpg'
```

### Removing a file
```ruby
response = client.remove url_to_file_picker_file
```

### Read operations
```ruby
url = client.convert_url url_to_file_picker_file, w: 100, h: 100
url = client.convert_url url_to_file_picker_file, {w: 100, h: 100}, expiry: 10.minutes.from_now.to_i

url = client.retrieve_url url_to_file_picker_file
url = client.retrieve_url url_to_file_picker_file, expiry: 10.minutes.from_now.to_i
```


## Contributing

1. Fork it ( http://github.com/<my-github-username>/ink_file_picker/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
