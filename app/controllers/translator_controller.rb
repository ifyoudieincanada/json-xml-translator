class TranslatorController < ApplicationController
  require 'json'
  require 'net/http'
  require 'uri'

  def index
    out_uri = URI.parse(get_destination)

    out_http = Net::HTTP.new(out_uri.host, out_uri.port)
    out_request = Net::HTTP::Post.new(uri.request_uri)

    out_request.body = get_hash.to_xml

    request.headers.each do |key, value|
      out_request[key] = value
    end

    in_response = out_http.request(out_request)

    render json: Hash.from_xml(in_response.body).to_json
  end

  private

  def get_destination
    params[:destination]
  end

  def get_hash
    params.select { |key, value| key != :destination }
  end

end
