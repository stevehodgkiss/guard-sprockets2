# Guard Sprockets 2

A Guard for Sprockets 2 that works with Rails, Sinatra or any other Rack app. 

# Usage

Add it to your Gemfile:

```ruby
gem 'guard-sprockets2'
```

Add the guard definition to your Guardfile:

```bash
bundle exec guard init sprockets2
```

Configure guard for your environment. The following options are available:

- `sprockets` - Required. Set it to an instance of `Sprockets::Environment`
- `assets_path` - Optional. The compiled assets path. Defaults to public/assets
- `precompile` - Optional. An array of regex's or strings which match files 
that need compiling. Defaults to `[ /\w+\.(?!js|css).+/, /application.(css|js)$/ ]`
- `digest` - Optional. Whether to include the digest in the filename. Defaults to true.

Example Rails and Sinatra apps can be found in the examples directory.

# Sinatra

```ruby
require './app'

guard 'sprockets2', :sprockets => App.sprockets do
  watch(%r{^assets/.+$})
  watch('app.rb')
end
```

# Rails

When Rails is loaded the defaults come from Rails' configuration.

```ruby
require './config/environment'

guard 'sprockets2' do
  watch(%r{^app/assets/.+$})
  watch('config/application.rb')
end
```
