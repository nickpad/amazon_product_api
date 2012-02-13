require 'base64'
require 'net/http'
require 'openssl'
require 'time'

# A very simple client for the Amazon Product Advertising API.
class Apazon
  ENDPOINT = URI.parse('https://ecs.amazonaws.co.uk/onca/xml')
  SERVICE = 'AWSECommerceService'
  VERSION = '2011-08-01'
  AMPERSAND = '&'
  COMMA = ','
  PERCENT = '%'
  HTTPS = 'https'
  HEADERS = {'User-Agent' => 'AmazonAPI', 'Accept' => 'application/xml'}
  DIGEST = OpenSSL::Digest::SHA256.new
  ENCODE = /([^a-zA-Z0-9_.~-]+)/

  attr_reader :connection

  def initialize(access_key_id, secret_access_key, associate_tag)
    @access_key_id = access_key_id
    @secret_access_key = secret_access_key
    @associate_tag = associate_tag
    @connection = Net::HTTP.new(ENDPOINT.host, ENDPOINT.port)
    @default_params = {
        'Service' => SERVICE,
        'Version' => VERSION,
        'AWSAccessKeyId' => @access_key_id,
        'AssociateTag' => @associate_tag
    }

    if ENDPOINT.scheme == HTTPS
      @connection.use_ssl = true
    end
  end

  def get(operation, response_groups, operation_params = {})
    base_params = {
        'Operation' => operation,
        'ResponseGroup' => response_groups.join(COMMA),
        'Timestamp' => Time.now.xmlschema
    }

    unsigned_params = operation_params.merge(@default_params.merge(base_params))

    signed_params = unsigned_params.merge({'Signature' => signature(unsigned_params)})

    request_uri = ENDPOINT.dup
    request_uri.query = query_string(signed_params)

    @connection.request(Net::HTTP::Get.new(request_uri.to_s, HEADERS))
  end

  private

  def url_encode(string)
    string.gsub(ENCODE) do
      PERCENT + $1.unpack('H2' * $1.bytesize).join(PERCENT).upcase
    end
  end

  def query_string(params)
    params.map do |key, value|
      "%s=%s" % [key, url_encode(value)]
    end.sort.join(AMPERSAND)
  end

  def signature(params)
    signable = "GET\n%s\n%s\n%s" % [ENDPOINT.host, ENDPOINT.path, query_string(params)]
    hmac = OpenSSL::HMAC.digest(DIGEST, @secret_access_key, signable)
    Base64.encode64(hmac).chomp
  end
end