# ActsAsIdentifier

[![Gem Version](https://badge.fury.io/rb/acts_as_identifier.svg)](https://badge.fury.io/rb/acts_as_identifier)

Automatically generate unique secure random string for one or more columns of ActiveRecord.

## Usage

> `ActsAsIdentifier` only generate identifier `before create`

```ruby
class Account < ActiveRecord::Base
  #
  # Note: without Rails, should include ActsAsIdentifier
  #
  #
  # with default options:
  #           column: :identifier
  #           length: 6
  #           prefix: ''
  #
  acts_as_identifier

  # extra column
  acts_as_identifier :slug, length: 6, prefix: 's-'
end
# => [Account(id: integer, name: string, tenant_id: string, slug: string)]

Account.create
# => #<Account:0x00007fcdb90830c0 id: 1, name: nil, tenant_id: nil, slug: "s-HuF2Od">
Account.create
# => #<Account:0x00007fcdb90830c0 id: 2, name: nil, tenant_id: nil, slug: "s-g3SIB8">

```

## Installation

```ruby
bundle add acts_as_identifier
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
