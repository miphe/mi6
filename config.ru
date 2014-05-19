require 'rubygems'
require 'bundler/setup'
require 'json'

Bundler.require(:default)

use Rack::ConditionalGet
use Rack::ETag

require 'nesta/env'
Nesta::Env.root = ::File.expand_path('.', ::File.dirname(__FILE__))

require 'nesta/app'
require 'susy'
require 'pp'

use Rack::Codehighlighter,
    :ultraviolet,
    :theme => "idle",
    :lines => false,
    :markdown => true,
    :element => "pre>code",
    :pattern => /\A:::(\w+)\s*(\n|&#x000A;)/i,
    :logging => false

run Nesta::App
