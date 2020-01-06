# ActsAsIdentifier

[![Gem Version](https://badge.fury.io/rb/acts_as_identifier.svg)](https://badge.fury.io/rb/acts_as_identifier)

Automatically generate unique secure random string for one or more columns of ActiveRecord.

## Usage

> `ActsAsIdentifier` only generate identifier `after_create_commit`

```ruby
class Account < ActiveRecord::Base
  #
  # Note: without Rails, should include ActsAsIdentifier
  #
  # def acts_as_identifier(attr = :identifier,
  #                            length: 6,
  #                            prefix: '',
  #                            id_column: :id,
  #                            chars: '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'.chars,
  #                            mappings: '3NjncZg82M5fe1PuSABJG9kiRQOqlVa0ybKXYDmtTxCp6Lh7rsIFUWd4vowzHE'.chars)
  #
  acts_as_identifier
  # or customize options:
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

## Testing

```shell
bundle exec rspec
# or test specific range
EXTRA_TEST=100000,1000000 bundle exec rspec
```
