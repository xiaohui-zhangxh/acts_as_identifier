# ActsAsIdentifier

[![Gem Version](https://badge.fury.io/rb/acts_as_identifier.svg)](https://badge.fury.io/rb/acts_as_identifier)

Automatically generate unique fixed-length string for one or more columns of ActiveRecord based on sequence column

## Usage

> `ActsAsIdentifier` only generate identifier `before_commit`

```ruby
class Account < ActiveRecord::Base
  include ActsAsIdentifier
  #
  # == default options
  #
  #      attr: :identifier,
  #      seed: 1,
  #    length: 6,
  #    prefix: nil,
  # id_column: :id,
  #     chars: '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ')
  #
  acts_as_identifier
  # or customize options:
  acts_as_identifier :slug, length: 6, prefix: 's-'
end
# => [Account(id: integer, name: string, tenant_id: string, slug: string)]

Account.create
# => #<Account:0x00007fcdb90830c0 id: 1, name: nil, tenant_id: nil, slug: "s-EPaPaP">
Account.create
# => #<Account:0x00007fcdb90830c0 id: 2, name: nil, tenant_id: nil, slug: "s-HSo0u4">
```

## Features

- *`ActiveRecord`*.find_by_decoded_*`identifier`*('s-EPaPaP') => Actually find by id, id is decoded from identifier, with this method you don't need to add extra index for *`identifier`*
- *`ActiveRecord`*.find_by_decoded_*`identifier`*!('s-EPaPaP') => equal to find_by_xx!
- *`ActiveRecord`*.*decode_`identifier`*('s-EPaPaP') => decode identifier to id
- *`ActiveRecord`*.*encode_`identifier`*(1) => encode id to identifier
- *`ActiveRecord`*.*`identifier`*_encoder => encoder instance, see [xencoder](https://github.com/xiaohui-zhangxh/xencoder)

## Installation

```ruby
bundle add acts_as_identifier
```

## Requirements

Use gem [`Xencoder`](https://github.com/xiaohui-zhangxh/xencoder/) to encode sequence number to fixed-length string.

## Contributing
Contribution directions go here.

## Testing

```shell
bundle exec rspec
```
