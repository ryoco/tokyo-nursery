#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'sinatra'
require "csv"
require "redis"

## TODO: remove to_i
class TokyoNursery < Sinatra::Base

  # TODO: use redis
  def get_locations
    no_tax = []
    tax = []
    read_csv = CSV.read("./csv_data/nursery_data.csv", {headers: true, return_headers: true})
    read_csv.each do |csv|
      if !csv.header_row?() and csv[14] != nil and csv[15] != nil
        if csv[12] == "有"
          no_tax.push([csv[0].to_i, csv[1], csv[14], csv[15], csv[4]])
        else
          tax.push([csv[0].to_i, csv[1], csv[14], csv[15], csv[4]])
        end
      end
    end
    [tax, no_tax]
  end

  def csv_to_redis
    redis = Redis.new
    if redis.dbsize <= 0
      read_csv = CSV.read("./csv_data/nursery_data.csv", {headers: false})
      read_csv.each do |csv|
        redis.rpush('nurseries-%d' % [csv[0].to_i], csv.to_a)
      end
    end
  end

  def get_csv_row(num)
    redis = Redis.new
    redis.lrange("nurseries-%d" % [num], 0, -1)
  end
    

  get '/' do
    unauth_loc, no_tax_unauth_loc = get_locations
    erb :index,
        :locals => {
          :unauth_loc => unauth_loc,
          :no_tax_unauth_loc => no_tax_unauth_loc
        }
  end
  
  get '/:number' do |num|
    csv_to_redis
    nu_data = get_csv_row(num)
    erb :detail,
        :locals => { 
          :nursery_name => nu_data[1],
          :nursery_block => nu_data[2],
          :nursery_address => nu_data[3],
          :nursery_station => nu_data[4],
          :nursery_company => nu_data[5],
          :nursery_start_time => nu_data[6],
          :nursery_end_time => nu_data[7],
          :nursery_capacity => nu_data[9],
          :nursery_start_date => nu_data[10],
          :nursery_phone_num => nu_data[11],
          :nursery_tax => nu_data[12],
          :nursery_note => nu_data[13],
    }
  end

end
