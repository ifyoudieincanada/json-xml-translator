class TranslatorController < ApplicationController

  skip_before_filter :verify_authenticity_token

  require 'json'
  require 'net/http'
  require 'uri'
  require 'gyoku'
  require 'nori'

  def post
    out_uri = URI.parse(get_destination)

    out_http = Net::HTTP.new(out_uri.host, out_uri.port)

    if params[:req_type] == 'get'
      out_request = Net::HTTP::Get.new(out_uri.request_uri)
    elsif params[:req_type] == 'post'
      out_request = Net::HTTP::Post.new(out_uri.request_uri)
      out_request.body = Gyoku.xml(get_hash).to_s
    end

    unless request.headers[:authentication].blank?
      out_request[:authentication] = request.headers[:authentication]
    end

    in_response = out_http.request(out_request)

    parser = Nori.new
    render json: parser.parse(in_response.body).to_json
  end

  private

  def get_destination
    Rails.logger.info { "destination: #{params[:destination]}" }
    params[:destination]
  end

  def get_hash
    Rails.logger.info { "site data: #{params[:site_data]}" }
    params[:site_data]
  end

end
