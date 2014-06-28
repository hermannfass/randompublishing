# RandomPublishing

Generate random web pages, strings, or colors.

## Installation

Add this line to your application's Gemfile:

    gem 'randompublishing'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install randompublishing

## Usage

    require 'randomstring'
    tr = TextRandomizer.new()
    puts tr.random_title(8)
    puts tr.random_paragraph(20)

## Contributing

1. Fork it ( https://github.com/[my-github-username]/randompublishing/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
