#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'sinatra'
require "csv"
require "redis"

## TODO: remove to_i
class TokyoNursery < Sinatra::Base

  def get_locations
    redis = Redis.new(:driver => :hiredis)
    no_tax = []
    tax = []
    redis.keys("nurseries-*").each do |key|
      row_data = redis.lrange(key, 0, -1)
      data = [row_data[0], row_data[1], row_data[14], row_data[15], row_data[4]]
      data = data.map{|a| a.nil? ? "" : a}
      if row_data[12] == "有"
        no_tax.push(data)
      else
        tax.push(data)
      end
    end
    [tax, no_tax]
  end

  def csv_to_redis
    redis = Redis.new(:driver => :hiredis)
    if redis.dbsize <= 0
      read_csv = CSV.read("./csv_data/nursery_data.csv", {headers: false})
      read_csv.each do |csv|
        key = "nurseries-%d" % csv[0]
        redis.lpush(key, csv.to_a.reverse)
      end
    end
  end

  def get_csv_row(num)
    redis = Redis.new(:driver => :hiredis)
    redis.lrange("nurseries-%d" % [num], 0, -1)
  end
    
  before do
    csv_to_redis
  end

  get '/' do
    unauth_loc, no_tax_unauth_loc = get_locations
    erb :index,
        locals: {
          unauth_loc: unauth_loc,
          no_tax_unauth_loc:  no_tax_unauth_loc,
        }
  end
  
  get '/detail/:number' do |num|
    nu_data = get_csv_row(num)
    erb :detail,
        locals: { 
          nursery_name: nu_data[1],
          nursery_block: nu_data[2],
          nursery_address: nu_data[3],
          nursery_station: nu_data[4],
          nursery_company: nu_data[5],
          nursery_start_time: nu_data[6],
          nursery_end_time: nu_data[7],
          nursery_capacity: nu_data[9].to_i,
          nursery_start_date: nu_data[10],
          nursery_phone_num: nu_data[11],
          nursery_tax: nu_data[12],
          nursery_note: nu_data[13],
        }
  end

end
