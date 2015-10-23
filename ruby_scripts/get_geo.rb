#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'roo-xls'

require "csv"
require "net/https"
require "open-uri"
require "json"
require "logger"
require "date"


class MakeCsvData

  ADDRESS_REGEXP = /\d+-\d+-\d+/

  def initialize(xls_file_names, csv_file_name)
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::DEBUG
    @xls_sheets = []
    xls_file_names.each do |xls_file_name|
      @xls_sheets.push(Roo::Excel.new(xls_file_name).sheet(0))
    end
    @csv_file_name = csv_file_name
  end

  def make_csv_file
    CSV.open(@csv_file_name, "wb") do |csv_row|
      csv_row << @xls_sheets[0].each.to_a[0]
      @xls_sheets.each_with_index do |xls_sheet, index|
        xls_sheet.each.to_a[1..-1].each do |row|
          row[0] = index * 1000 + row[0].to_i
          json = get_geo_data(row)
          format_json(json, row, csv_row)
        end
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
      @logger.debug(json["status"])
      sleep(0.3)
      json
    end
  end

  def format_json(json, row, csv)
    if json["status"] == "OK"
      json["results"].each do |j|
        location = j["geometry"]["location"]
        if row[6].is_a?(Integer) 
          row[6] = "%02d:%02d" % [row[6] / 3600, (row[6] % 3600) / 60]
        end
        if row[7].is_a?(Integer)
          row[7] = "%02d:%02d" % [row[7] / 3600, (row[7] % 3600) / 60]
        end
        if row[10].is_a?(Integer)
          row[10] = DateTime.new(1899,12,30) + row[10].days
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
  csv_file_name = "./csv_data/nursery_data.csv"
  xls_file_names = ["./baby.xls", "./sonohoka.xls"]
else
  csv_file_name = ARGV[0]
  xls_file_names = ARGV[1..-1]
end

mcd = MakeCsvData.new(xls_file_names, csv_file_name)
mcd.make_csv_file
