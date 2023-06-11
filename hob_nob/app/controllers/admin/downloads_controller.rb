class Admin::DownloadsController < ApplicationController
  require 'open-uri'

  def new
    data = open(params[:url])
    send_data data.read, :type => data.content_type, :x_sendfile => true, :filename=>"#{params[:url].split('/').last.split('?').first}"
  end
end
