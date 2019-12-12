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

  # with default options:
  #           column: :identifier
  #           length: 6
  #   case sensitive: true
  #         max_loop: 100
  #            scope: []
  acts_as_identifier

  # extra column
  acts_as_identifier :slug, length: 8, case_sensitive: false, max_loop: 1000, scope: [:tenant_id]
end
# => [Account(id: integer, name: string, tenant_id: string, identifier: string, slug: string)]

Account.create
# => #<Account:0x00007fcdb90830c0 id: 1, name: nil, tenant_id: nil, identifier: "PWbYHd", slug: "5fabb1e7">

```

## Installation

```ruby
bundle add acts_as_identifier
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
