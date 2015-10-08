#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

threads 1,6
workers 2
preload_app!

port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'
