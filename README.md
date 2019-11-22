# hash-mapper

Map a Ruby hash into another Ruby hash.

## Usage

```ruby
m = HashMapper.new do
  key :name, source: :Name
  key :last_name, source: :LastName, :allow_nil, then: proc { |o| o.value + '!' }
  key :full_name, source: [:Name, :LastName], then: proc { |o|
    "#{o.value.first} W. #{o.value.second}"
  }
  key :surname, eq: 'Wheeler'
  key :zip
  merge { |o| { extra: o.Name + '!' } }
end
m.run(Name: 'Bob', LastName: 'Fuller', zip: 'Boo!')
# => {name: 'Bob', last_name: 'Bob', full_name: 'Bob W. Fuller', surname: 'Wheeler', extra: 'Bob!', zip: 'Boo!' }
```

## Installation

```
gem install hash-mapper
```

## License

See LICENSE
