require 'rubygems'
require 'bundler'

Bundler.require

require './env' if File.exists?('env.rb')

require './app'
# run Sinatra::Application
run TokyoNursery
