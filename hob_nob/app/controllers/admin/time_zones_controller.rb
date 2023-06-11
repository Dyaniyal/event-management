class Admin::TimeZonesController < ApplicationController
  
  layout 'admin'
  require 'tasks/time_zone_api'
  require 'uri'
    before_filter :authenticate_user
  
  def index
    city_name = params[:city_name]
    country_name = params[:country_name]
    timestamp = params[:timestamp].to_datetime.to_i
    @timestamp = params[:timestamp].to_datetime
    if city_name.present? && country_name.present?
      city_name = URI.encode(city_name)
      country_name = URI.encode(country_name)
      position = TimeZoneApi.get_lat_long_from_city(city_name,country_name)
      if position["results"].present?
        lat = position["results"][0]["geometry"]["location"]["lat"]
        lng = position["results"][0]["geometry"]["location"]["lng"]
        timezone_detail = TimeZoneApi.get_time_zone(lat,lng,timestamp)
        @timezone = timezone_detail["timeZoneId"].split("/").second.titleize if timezone_detail.present?
        time_zone_id = timezone_detail["timeZoneId"]
        time_zone_id = "Asia/Kolkata" if time_zone_id == "Asia/Calcutta"
        @timezone = ActiveSupport::TimeZone.zones_map.values.collect{|z| [z.tzinfo.name, z.at(params[:timestamp].to_datetime).formatted_offset]}.select{|t| t[0] == time_zone_id}
        @timezone = @timezone.last.last if @timezone.present?
        signle_timezone = ActiveSupport::TimeZone.all.map{|e| ["#{e.at(params[:timestamp].to_datetime).formatted_offset}", e.name]}
        timezone_data = signle_timezone.select{ |a| a[0] == @timezone}
        @timezone = "GMT" + timezone_data.first[0] if timezone_data.present?
      end     
    end 
  end
end
