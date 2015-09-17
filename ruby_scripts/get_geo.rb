#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'roo-xls'

require "csv"
require "net/https"
require "open-uri"
require "json"


class MakeCsvData

  ADDRESS_REGEXP = /\d+-\d+-\d+/

  def initialize(xls_file_name)
    @xls_sheet = Roo::Excel.new(xls_file_name).sheet(0)
  end

  def make_csv_file
    csv_file = CSV.open("./csv_data/nursery_data.csv", "wb") do |csv_row|
      @xls_sheet.each do |row|
        #unless row.header_row?()
          row[0] = row[0].to_i
          json = get_geo_data(row)
          format_json(json, row, csv_row)
        #end
      end
    end
  end

  private

  def get_geo_data(row)
    address = row[3].gsub("－", "-")
    address = address.split(ADDRESS_REGEXP).first + ADDRESS_REGEXP.match(address).to_s
    gapi = "https://maps.googleapis.com/maps/api/geocode/json"
    queries = "?address=%s,%s&language=ja" % [address, row[2]]

    uri = URI(URI::encode(gapi + queries))
    Net::HTTP.start(uri.host, uri.port,
      :use_ssl => uri.scheme == 'https') do |http|
      request = Net::HTTP::Get.new(uri)
      response = http.request(request)
      json = JSON.parse(response.body)
      sleep(1)
      json
    end
  end

  def format_json(json, row, csv)
    if json["status"] == "OK"
      json["results"].each do |j|
        location = j["geometry"]["location"]
        if row[6].is_a?(Integer) && row[7].is_a?(Integer)
          row[6] = "%02d:%02d" % [row[6] / 3600, (row[6] % 3600) / 60]
          row[7] = "%02d:%02d" % [row[7] / 3600, (row[7] % 3600) / 60]
        end
        if row[12].nil?
          row[12] = "無"
        end
        row.push(location["lat"])
        row.push(location["lng"])
        row.push(j["place_id"])
        row.push(j["formatted_address"])
        csv << row
      end
    else
      csv << row
    end
  end
end


if ARGV.empty?
  xls_file_name = "./baby.xls"
else
  xls_file_name = ARGV[0]
end

mcd = MakeCsvData.new(xls_file_name)
mcd.make_csv_file
